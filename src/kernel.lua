-- There should be only one instance of this code
-- running for a given lua state




--[[
	Queue
--]]
local Queue = {}
setmetatable(Queue, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local Queue_mt = {
	__index = Queue;
}

function Queue.init(self, first, last, name)
	first = first or 1;
	last = last or 0;

	local obj = {
		first=first, 
		last=last, 
		name=name};

	setmetatable(obj, Queue_mt);

	return obj
end

function Queue.create(self, first, last, name)
	first = first or 1
	last = last or 0

	return self:init(first, last, name);
end

--[[
function Queue.new(name)
	return Queue:init(1, 0, name);
end
--]]

function Queue:enqueue(value)
	--self.MyList:PushRight(value)
	local last = self.last + 1
	self.last = last
	self[last] = value

	return value
end

function Queue:pushFront(value)
	-- PushLeft
	local first = self.first - 1;
	self.first = first;
	self[first] = value;
end

function Queue:dequeue(value)
	-- return self.MyList:PopLeft()
	local first = self.first

	if first > self.last then
		return nil, "list is empty"
	end
	
	local value = self[first]
	self[first] = nil        -- to allow garbage collection
	self.first = first + 1

	return value	
end

function Queue:length()
	return self.last - self.first+1
end

-- Returns an iterator over all the current 
-- values in the queue
function Queue:entries(func, param)
	local starting = self.first-1;
	local len = self:length();

	local closure = function()
		starting = starting + 1;
		return self[starting];
	end

	return closure;
end



-- Task specifics
local Task = {}

setmetatable(Task, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local Task_mt = {
	__index = Task,
}

function Task.init(self, aroutine, ...)

	local obj = {
		routine = coroutine.create(aroutine), 
	}
	setmetatable(obj, Task_mt);
	
	obj:setParams({...});

	return obj
end

function Task.create(self, aroutine, ...)
	-- The 'aroutine' should be something that is callable
	-- either a function, or a table with a meta '__call'
	-- implementation.  Checking with type == 'function'
	-- is not good enough as it will miss the meta __call cases

	return self:init(aroutine, ...)
end


function Task.getStatus(self)
	return coroutine.status(self.routine);
end

-- A function that can be used as a predicate
function Task.isFinished(self)
	return task:getStatus() == "dead"
end


function Task.setParams(self, params)
	self.params = params

	return self;
end

function Task.resume(self)
--print("Task, RESUMING: ", unpack(self.params));
	return coroutine.resume(self.routine, unpack(self.params));
end

function Task.yield(self, ...)
	return coroutine.yield(...)
end




-- kernel state
local 	ContinueRunning = true;
local 	TaskID = 0;
local	TasksSuspendedForSignal = {};
local	TasksReadyToRun = Queue();
local CurrentTask = nil;




-- Scheduler Related
local function tasksPending()
	return TasksReadyToRun:length();
end

-- put a task on the ready list
-- the 'task' should be something that can be executed,
-- whether it's a function, functor, or something that has a '__call'
-- metamethod implemented.
-- The 'params' is a table of parameters which will be passed to the function
-- when it's ready to run.
local function scheduleTask(task, params)
	--print("Scheduler.scheduleTask: ", task, params)
	params = params or {}
	
	if not task then
		return false, "no task specified"
	end

	task:setParams(params);
	TasksReadyToRun:enqueue(task);	
	task.state = "readytorun"

	return task;
end

local function removeTask(tsk)
	--print("REMOVING DEAD FIBER: ", fiber);
	return true;
end

local function inMainFiber()
	return coroutine.running() == nil; 
end

local function getCurrentTask()
	return CurrentTask;
end

local function suspendCurrentTask(...)
	CurrentTask.state = "suspended"
end

local function SchedulerStep()
	-- Now check the regular fibers
	local task = TasksReadyToRun:dequeue()

	-- If no fiber in ready queue, then just return
	if task == nil then
		--print("Scheduler.step: NO TASK")
		return true
	end

	if task:getStatus() == "dead" then
		removeFiber(task)

		return true;
	end

	-- If the task we pulled off the active list is 
	-- not dead, then perhaps it is suspended.  If that's true
	-- then it needs to drop out of the active list.
	-- We assume that some other part of the system is responsible for
	-- keeping track of the task, and rescheduling it when appropriate.
	if task.state == "suspended" then
		--print("suspended task wants to run")
		return true;
	end

	-- If we have gotten this far, then the task truly is ready to 
	-- run, and it should be set as the currentFiber, and its coroutine
	-- is resumed.
	CurrentTask = task;
	local results = {task:resume()};

	-- once we get results back from the resume, one
	-- of two things could have happened.
	-- 1) The routine exited normally
	-- 2) The routine yielded
	--
	-- In both cases, we parse out the results of the resume 
	-- into a success indicator and the rest of the values returned 
	-- from the routine
	--local pcallsuccess = results[1];
	--table.remove(results,1);

	local success = results[1];
	table.remove(results,1);

--print("PCALL, RESUME: ", pcallsuccess, success)

	-- no task is currently executing
	CurrentTask = nil;


	if not success then
		print("RESUME ERROR")
		print(unpack(results));
	end

	-- Again, check to see if the task is dead after
	-- the most recent resume.  If it's dead, then don't
	-- bother putting it back into the readytorun queue
	-- just remove the task from the list of tasks
	if task:getStatus() == "dead" then
		removeTask(task)

		return true;
	end

	-- The only way the task will get back onto the readylist
	-- is if it's state is 'readytorun', otherwise, it will
	-- stay out of the readytorun list.
	if task.state == "readytorun" then
		scheduleTask(task, results);
	end
end



-- Kernel specific routines

local function getNewTaskID()
	TaskID = TaskID + 1;
	return TaskID;
end

local function getCurrentTaskID()
	return getCurrentTask().TaskID;
end

local function spawn(func, ...)
	local task = Task(func, ...)
	task.TaskID = getNewTaskID();
	scheduleTask(task, {...});
	
	return task;
end

local function suspend(...)
	suspendCurrentTask();
	return yield(...)
end

local function yield(...)
	return coroutine.yield(...);
end


local function signalOne(eventName, ...)
	if not TasksSuspendedForSignal[eventName] then
		return false, "event not registered", eventName
	end

	local nTasks = #TasksSuspendedForSignal[eventName]
	if nTasks < 1 then
		return false, "no tasks waiting for event"
	end

	local suspended = TasksSuspendedForSignal[eventName][1];

	scheduleTask(suspended,{...});
	table.remove(TasksSuspendedForSignal[eventName], 1);

	return true;
end

local function signalAll(eventName, ...)
	if not TasksSuspendedForSignal[eventName] then
		return false, "event not registered"
	end

	local nTasks = #TasksSuspendedForSignal[eventName]
	if nTasks < 1 then
		return false, "no tasks waiting for event"
	end

	for i=1,nTasks do
		scheduleTask(TasksSuspendedForSignal[eventName][1],{...});
		table.remove(TasksSuspendedForSignal[eventName], 1);
	end

	return true;
end

local function waitForSignal(eventName)
	local cTask = getCurrentTask();

	if cTask == nil then
		return false, "not currently in a running task"
	end

	if not TasksSuspendedForSignal[eventName] then
		TasksSuspendedForSignal[eventName] = {}
	end

	table.insert(TasksSuspendedForSignal[eventName], cTask);

	return suspend()
end

local function onSignal(self, func, eventName)
	local function closure()
		waitForSignal(eventName)
		func();
	end

	return spawn(closure)
end


local function run(func, ...)
	if func ~= nil then
		spawn(func, ...)
	end

	while (ContinueRunning) do
		SchedulerStep();		
	end
end

local function halt(self)
	ContinueRunning = false;
end

local exports = {
	halt = halt;

    run = run;

    spawn = spawn;
    suspend = suspend;
    yield = yield;
    
    onSignal = onSignal;
    signalAll = signalAll;
    signalOne = signalOne;
    waitForSignal = waitForSignal;

}

-- put everything into the global namespace by default
for k,v in pairs(exports) do
	_G[k] = v;
end


return exports;

from mandelbrot_task import *
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
from mpi4py import MPI 
import numpy as np
import sys
import time

# some parameters
MANAGER = 0       # rank of manager
TAG_TASK      = 1 # task       message tag
TAG_TASK_DONE = 2 # tasks done message tag
TAG_DONE      = 3 # done       message tag

def manager(comm, tasks):
    """
    The manager.

    Parameters
    ----------
    comm : mpi4py.MPI communicator
        MPI communicator
    tasks : list of objects with a do_task() method perfroming the task
        List of tasks to accomplish

    Returns
    -------
    ... ToDo ...
    """
    size = comm.Get_size()
    TasksDoneByWorker = [0] * size
    num_tasks_total = len(tasks)
    completed_tasks = []

    for worker_rank in range(1, size):
        if tasks:
            next_task = tasks.pop()
            comm.send(next_task, dest=worker_rank, tag=TAG_TASK)

    while len(completed_tasks) < num_tasks_total:
        status = MPI.Status()
        result_task, worker_rank = comm.recv(source=MPI.ANY_SOURCE, tag=TAG_TASK_DONE, status=status)

        completed_tasks.append(result_task)
        TasksDoneByWorker[worker_rank] += 1

        if tasks:
            next_task = tasks.pop()
            comm.send(next_task, dest=worker_rank, tag=TAG_TASK)
        else:
            comm.send(None, dest=worker_rank, tag=TAG_DONE)
    for _ in range(1, size):
        comm.recv(source=MPI.ANY_SOURCE, tag=TAG_DONE)

    return completed_tasks, TasksDoneByWorker

def worker(comm):
    """
    The worker.

    Parameters
    ----------
    comm : mpi4py.MPI communicator
        MPI communicator
    """

    rank = comm.Get_rank()

    while True:
        status = MPI.Status()
        task = comm.recv(source=MANAGER, tag=MPI.ANY_TAG, status=status)

        if status.tag == TAG_TASK:
            task.do_work()
            comm.send((task, rank), dest=MANAGER, tag=TAG_TASK_DONE)

        elif status.tag == TAG_DONE:
            comm.send(rank, dest=MANAGER, tag=TAG_DONE)
            break

def readcmdline(rank):
    """
    Read command line arguments

    Parameters
    ----------
    rank : int
        Rank of calling MPI process

    Returns
    -------
    nx : int
        number of gridpoints in x-direction
    ny : int
        number of gridpoints in y-direction
    ntasks : int
        number of tasks
    """
    # report usage
    if len(sys.argv) != 4:
        if rank == MANAGER:
            print("Usage: manager_worker nx ny ntasks")
            print("  nx     number of gridpoints in x-direction")
            print("  ny     number of gridpoints in y-direction")
            print("  ntasks number of tasks")
        sys.exit()

    # read nx, ny, ntasks
    nx = int(sys.argv[1])
    if nx < 1:
        sys.exit("nx must be a positive integer")
    ny = int(sys.argv[2])
    if ny < 1:
        sys.exit("ny must be a positive integer")
    ntasks = int(sys.argv[3])
    if ntasks < 1:
        sys.exit("ntasks must be a positive integer")

    return nx, ny, ntasks


if __name__ == "__main__":

    # get COMMON WORLD communicator, size & rank
    comm    = MPI.COMM_WORLD
    size    = comm.Get_size()
    my_rank = comm.Get_rank()

    # report on MPI environment
    if my_rank == MANAGER:
        print(f"MPI initialized with {size:5d} processes")

    # read command line arguments
    nx, ny, ntasks = readcmdline(my_rank)

    # start timer
    timespent = - time.perf_counter()

    # trying out ... YOUR MANAGER-WORKER IMPLEMENTATION HERE ...
    x_min = -2.
    x_max  = +1.
    y_min  = -1.5
    y_max  = +1.5
    if my_rank == MANAGER:
        M = mandelbrot(x_min, x_max, nx, y_min, y_max, ny, ntasks)
        tasks = M.get_tasks()
        start_time = time.perf_counter()
        result = manager(comm, tasks)
        completed_tasks = result[0]
        TasksDoneByWorker = result[1]
        m = M.combine_tasks(completed_tasks)
        plt.imshow(m.T, cmap="gray", extent=[x_min, x_max, y_min, y_max])
        plt.savefig("mandelbrot.png")
        timespent += time.perf_counter()
        print(f"Run took {timespent:f} seconds")
        for i, tasks_done in enumerate(TasksDoneByWorker):
            if i != MANAGER:
                print(f"Worker {i} completed {tasks_done} tasks.")
        #for i in range(size):
            ##  continue
            #print(f"Process {i:5d} has done {TasksDoneByWorker[i]:10d} tasks")
        #print("Done.")
    else:
        worker(comm)
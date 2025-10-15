from mpi4py import MPI
import numpy as np

def sum_of_ranks_pickle():
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()
    
    # compute sum
    rank_sum = comm.allreduce(rank, op=MPI.SUM)
    
    if rank == 0:
        print(f"Sum of ranks using pickle-based communication: {rank_sum}")

def sum_of_ranks_buffer():
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()
    rank_array = np.array([rank], dtype='i')
    rank_sum_array = np.zeros(1, dtype='i')
    
    # compute sum
    comm.Allreduce(rank_array, rank_sum_array, op=MPI.SUM)
    
    if rank == 0:
        print(f"Sum of ranks using buffer-based communication: {rank_sum_array[0]}")

if __name__ == "__main__":
    sum_of_ranks_pickle()
    sum_of_ranks_buffer()

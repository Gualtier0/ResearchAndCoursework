from mpi4py import MPI
import numpy as np

def ghost_cell_exchange():
    comm = MPI.COMM_WORLD
    size = comm.Get_size()
    rank = comm.Get_rank()
    dims = MPI.Compute_dims(size, [0, 0])  
    periods = [True, True]
    reorder = True
    cart_comm = comm.Create_cart(dims, periods=periods, reorder=reorder)

    coords = cart_comm.Get_coords(rank)

    nbr_east, nbr_west = cart_comm.Shift(direction=1, disp=1)
    nbr_north, nbr_south = cart_comm.Shift(direction=0, disp=1)

    print(f"Rank {rank}: Coords {coords}, East {nbr_east}, West {nbr_west}, "
          f"North {nbr_north}, South {nbr_south}")

    rank_data = np.array([rank], dtype='i')
    recv_east = np.zeros(1, dtype='i')
    recv_west = np.zeros(1, dtype='i')
    recv_north = np.zeros(1, dtype='i')
    recv_south = np.zeros(1, dtype='i')

    cart_comm.Sendrecv(rank_data, dest=nbr_east, recvbuf=recv_west, source=nbr_west)
    cart_comm.Sendrecv(rank_data, dest=nbr_west, recvbuf=recv_east, source=nbr_east)

    cart_comm.Sendrecv(rank_data, dest=nbr_north, recvbuf=recv_south, source=nbr_south)
    cart_comm.Sendrecv(rank_data, dest=nbr_south, recvbuf=recv_north, source=nbr_north)

    print(f"Rank {rank}: received from East {recv_east[0]}, West {recv_west[0]}, "
          f"North {recv_north[0]}, South {recv_south[0]}")

if __name__ == "__main__":
    ghost_cell_exchange()

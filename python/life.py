# life.py simulates John Conway's Game of Life with random initial states# -----------------------------------------------------------------------------import sys, random, pygamefrom pygame.locals import *# -----------------------------------------------------------------------------# GLOBALS# The title and version of this programtitle, version = "The Game of Life", "1.0" # The dimensions of each cell (in pixels)cell_dimensions = (5,5) # The framerate of the game (in milliseconds)framerate = 60 # The fraction of the board occupied by cells when randomly generatedoccupancy = 0.25 # Colors used to represent the cellscolors = { 0:(0,0,0), 1:(200,200,100) } # -----------------------------------------------------------------------------# FUNCTIONS# Main functiondef main(args):	 # Get the board dimensions (in cells, not pixels) from command-line input	if len(args) != 3: sys.exit("USAGE: life.py X_CELLS Y_CELLS")	board_dimensions = (int(args[1]),int(args[2]))	 # Initialize pygame elements	screen, bg, clock = init(board_dimensions)	 # Initialize random board	board = make_random_board(board_dimensions)	 # Enter the game loop	quit_game = False	while not quit_game:		 # Slow things down to match the framerate		clock.tick(framerate)		 # Update the board		update_board(board)		 # Draw the board on the background		draw_board(board, bg)		 # Blit bg to the screen, flip display buffers		screen.blit(bg, (0,0))		pygame.display.flip()		 # Queue user input to catch QUIT signals		for e in pygame.event.get():			if e.type == QUIT: quit_game = True	 # Print farewell message	print "Thanks for watching!" # Initialize pygame elementsdef init(board_dimensions):	 # Grab hard-coded global values	global title, version, cell_dimensions	 # Initialize the pygame modules	pygame.init()	 # Determine and set the screen dimensions	dimensions = (board_dimensions[0]*cell_dimensions[0],				  board_dimensions[1]*cell_dimensions[1])	screen = pygame.display.set_mode(dimensions)	 # Set the title string of the root window	pygame.display.set_caption(title+" "+version)	 # Grab the background surface of the screen	bg = screen.convert()	 # Grab the game clock	clock = pygame.time.Clock()	 # Return the screen, the background surface, and the game clock	return screen, bg, clock # Create a "seed" board of given dimensions at randomdef make_random_board(board_dimensions):	 # Grab hard-coded global values	global occupancy	 # Instantiate the board as a dictionary with a fraction occupied	# 0 indicates an empty cell; 1 indicates an occupied cell	board = dict()	for x in range(board_dimensions[0]):		for y in range(board_dimensions[1]):			if random.random() < occupancy: board[(x,y)] = 1			else: board[(x,y)] = 0	 # Return the board	return board # Update the board according to the rules of the gamedef update_board(board):	 # For every cell in the board...	for cell in board:		 # How many occupied neighbors does this cell have?		neighbors = count_neighbors(cell, board)		 # If the cell is empty and has 3 neighbors, mark it for occupation		if board[cell] == 0 and neighbors == 3: board[cell] = 2		 # On the other hand, if the cell is occupied and doesn't have 2 or 3		# neighbors, mark it for death		elif board[cell] == 1 and not neighbors in [ 2, 3 ]: board[cell] = -1	 # Now, go through it again, making all the approved changes	for cell in board:		if board[cell] == 2: board[cell] = 1		if board[cell] == -1: board[cell] = 0 # Return the number of occupied neighbors this cell hasdef count_neighbors(cell, board):	 # Figure out the potential neighboring cells (need to watch the edges)	neighbors = [ (cell[0]-1,cell[1]), (cell[0]-1,cell[1]-1),				  (cell[0],cell[1]-1), (cell[0]+1,cell[1]-1),				  (cell[0]+1,cell[1]), (cell[0]+1,cell[1]+1),				  (cell[0],cell[1]+1), (cell[0]-1,cell[1]+1) ]	 # For each potential neighbor, if the cell is occupied add one to the score	score = 0	for neighbor in neighbors:		 # Is this a real neighbor, or is it out-of-bounds?		if neighbor in board.keys():			 # Remember that neighbors which are marked for death count, too!			if board[neighbor] in [ 1, -1 ]: score += 1	 # Return the score	return score # Draw the board on the backgrounddef draw_board(board, bg):	 # Grab hard-coded global values	global cell_dimensions	 # Draw every cell in the board as a rectangle on the screen	for cell in board:		rectangle = (cell[0]*cell_dimensions[0],cell[1]*cell_dimensions[1],					 cell_dimensions[0],cell_dimensions[1])		pygame.draw.rect(bg, colors[board[cell]], rectangle) # -----------------------------------------------------------------------------# The following code is executed upon command-line invocationif __name__ == "__main__": main(sys.argv) # -----------------------------------------------------------------------------# EOF# life.py simulates John Conway's Game of Life with random initial states
# -----------------------------------------------------------------------------
import sys, random, pygame
from pygame.locals import *
# -----------------------------------------------------------------------------
# GLOBALS
# The title and version of this program
title, version = "The Game of Life", "1.0"

# The dimensions of each cell (in pixels)
cell_dimensions = (6,6)

# The framerate of the game (in milliseconds)
framerate = 20

# The fraction of the board occupied by cells when randomly generated
occupancy = 0.25

# Colors used to represent the cells
colors = { 0:(0,0,0), 1:(150,200,100) }

# -----------------------------------------------------------------------------
# FUNCTIONS
# Main function
def main(args):

	# Get the board dimensions (in cells, not pixels) from command-line input
	if len(args) != 3: sys.exit("USAGE: life.py X_CELLS Y_CELLS")
	board_dimensions = (int(args[1]),int(args[2]))

	# Initialize pygame elements
	screen, bg, clock = init(board_dimensions)

	# Initialize random board
	board = make_random_board(board_dimensions)

	#board = seedBoardPatternA1(board_dimensions)


	# Enter the game loop
	quit_game = False
	while not quit_game:

		# Slow things down to match the framerate
		clock.tick(framerate)

		# Update the board
		update_board(board)

		# Draw the board on the background
		draw_board(board, bg)

		# Blit bg to the screen, flip display buffers
		screen.blit(bg, (0,0))
		pygame.display.flip()

		# Queue user input to catch QUIT signals
		for e in pygame.event.get():
			if e.type == QUIT: quit_game = True

	# Print farewell message
	print "Thanks for watching!"

def seedBoardPatternA1(board_dimensions):
	board = dict()
	for x in range(board_dimensions[0]):
		for y in range(board_dimensions[1]):
			board[(x,y)] = 0

	board[(10,10)] = 1
	board[(10,11)] = 1
	board[(11,9)] = 1
	board[(11,10)] = 1
	board[(11,11)] = 1
	board[(11,12)] = 1
	board[(12,10)] = 1
	board[(12,11)] = 1
	board[(12,12)] = 1
	board[(12,13)] = 1
	board[(12,14)] = 1
	board[(13,12)] = 1
	board[(13,13)] = 1
	board[(13,14)] = 1

	return board


# Initialize pygame elements
def init(board_dimensions):

	# Grab hard-coded global values
	global title, version, cell_dimensions

	# Initialize the pygame modules
	pygame.init()

	# Determine and set the screen dimensions
	dimensions = (board_dimensions[0]*cell_dimensions[0],
				  board_dimensions[1]*cell_dimensions[1])
	screen = pygame.display.set_mode(dimensions)

	# Set the title string of the root window
	pygame.display.set_caption(title+" "+version)

	# Grab the background surface of the screen
	bg = screen.convert()

	# Grab the game clock
	clock = pygame.time.Clock()

	# Return the screen, the background surface, and the game clock
	return screen, bg, clock

# Create a "seed" board of given dimensions at random
def make_random_board(board_dimensions):

	# Grab hard-coded global values
	global occupancy

	# Instantiate the board as a dictionary with a fraction occupied
	# 0 indicates an empty cell; 1 indicates an occupied cell
	board = dict()
	for x in range(board_dimensions[0]):
		for y in range(board_dimensions[1]):
			if random.random() < occupancy: board[(x,y)] = 1
			else: board[(x,y)] = 0

	# Return the board
	return board

# Update the board according to the rules of the game
def update_board(board):

	# For every cell in the board...
	for cell in board:

		# How many occupied neighbors does this cell have?
		neighbors = count_neighbors(cell, board)

		# If the cell is empty and has 3 neighbors, mark it for occupation
		if board[cell] == 0 and neighbors == 3: board[cell] = 2

		# On the other hand, if the cell is occupied and doesn't have 2 or 3
		# neighbors, mark it for death
		elif board[cell] == 1 and not neighbors in [ 2, 3 ]: board[cell] = -1

	# Now, go through it again, making all the approved changes
	for cell in board:
		if board[cell] == 2: board[cell] = 1
		if board[cell] == -1: board[cell] = 0

# Return the number of occupied neighbors this cell has
def count_neighbors(cell, board):

	# Figure out the potential neighboring cells (need to watch the edges)
	neighbors = [ (cell[0]-1,cell[1]), (cell[0]-1,cell[1]-1),
				  (cell[0],cell[1]-1), (cell[0]+1,cell[1]-1),
				  (cell[0]+1,cell[1]), (cell[0]+1,cell[1]+1),
				  (cell[0],cell[1]+1), (cell[0]-1,cell[1]+1) ]

	# For each potential neighbor, if the cell is occupied add one to the score
	score = 0
	for neighbor in neighbors:

		# Is this a real neighbor, or is it out-of-bounds?
		if neighbor in board.keys():

			# Remember that neighbors which are marked for death count, too!
			if board[neighbor] in [ 1, -1 ]: score += 1

	# Return the score
	return score

# Draw the board on the background
def draw_board(board, bg):

	# Grab hard-coded global values
	global cell_dimensions

	# Draw every cell in the board as a rectangle on the screen
	for cell in board:
		rectangle = (cell[0]*cell_dimensions[0],cell[1]*cell_dimensions[1],
					 cell_dimensions[0],cell_dimensions[1])
		pygame.draw.rect(bg, colors[board[cell]], rectangle)

# -----------------------------------------------------------------------------
# The following code is executed upon command-line invocation
if __name__ == "__main__": main(sys.argv)

# -----------------------------------------------------------------------------
# EOF

import random
import sys

def generate_test_file(filename, num_coordinates=100):
    """Generate a test file with random coordinates."""

    with open(filename, 'w') as f:
        for _ in range(num_coordinates):
            x = random.randint(0, 32767)
            y = random.randint(0, 32767)
            f.write(f"{x}\t{y}\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python generate_test_file.py <filename> <number_of_coordinates>")
        sys.exit(1)

    filename = sys.argv[1]
    try:
        num_coordinates = int(sys.argv[2])
    except ValueError:
        print("Error: number_of_coordinates must be an integer.")
        sys.exit(1)

    generate_test_file(filename, num_coordinates)
    print(f"Test file '{filename}' with {num_coordinates} coordinates created successfully!")
    
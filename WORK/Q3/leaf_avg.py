import csv
import sys

def calculate_highest_average(csv_file):
    highest_avg = float('-inf')
    best_plant = ""

    with open(csv_file, newline='', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Skip the header row
        for row in reader:
            plant = row[0]
            leaf_count = row[2]
            # Split the leaf count into individual values and convert them to integers
            try:
                values = list(map(int, leaf_count.split()))
            except ValueError:
                continue  # Skip rows with invalid or empty leaf count

            # Calculate the average of the values
            if values:
                avg = sum(values) / len(values)
                if avg > highest_avg:
                    highest_avg = avg
                    best_plant = plant

    
    if best_plant:
        print(f"{best_plant}: Highest Average = {highest_avg:.2f}")
    else:
        print("No valid data found for averages.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python calculate_avg.py <csv_file>")
        sys.exit(1)
    csv_file = sys.argv[1]
    calculate_highest_average(csv_file)

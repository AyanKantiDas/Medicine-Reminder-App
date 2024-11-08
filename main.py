from flask import Flask, request, jsonify
import pandas as pd

app = Flask(__name__)

# Load the CSV file
file_path = 'C:/Users/Ayan Kanti Das/OneDrive/Desktop/medic bot/Medicine_Details.csv'
medicine_data = pd.read_csv(file_path)


class MedicineBot:
    def __init__(self, data):
        self.data = data

    def get_medicine_info(self, medicine_name):
        # Search for the medicine by name
        medicine_info = self.data[self.data['Medicine Name'].str.contains(medicine_name, case=False, na=False)]
        if medicine_info.empty:
            return None

        # Extract relevant information
        info = medicine_info.iloc[0]
        result = {
            'Medicine Name': info['Medicine Name'],
            'Composition': info['Composition'],
            'Uses': info['Uses'],
            'Side Effects': info['Side_effects'],
            'Manufacturer': info['Manufacturer']
        }
        return result


bot = MedicineBot(medicine_data)


@app.route('/get_medicine_info', methods=['POST'])
def get_medicine_info():
    data = request.get_json()
    medicine_name = data.get('medicine_name')
    if not medicine_name:
        return jsonify({'error': 'Medicine name is required'}), 400

    info = bot.get_medicine_info(medicine_name)
    if info is None:
        return jsonify({'error': 'No information found for the given medicine name'}), 404

    return jsonify(info)


if __name__ == '__main__':
    app.run(debug=True)
from flask import Flask, request, jsonify
import urllib.request
import urllib.parse
import random
import psycopg2
from datetime import datetime;
import base64;

app = Flask(__name__)

db_config = {
    'dbname': '',
    'user': '',
    'password': '',
    'host': '',
    'port': ''
}

#Helper functions

# Helper function to execute SQL queries
def execute_query(query, params=None):
    connection = psycopg2.connect(**db_config)
    cursor = connection.cursor()

    if params:
        cursor.execute(query, params)
    else:
        cursor.execute(query)

    connection.commit()
    
    # Check if the query is expected to return data
    if cursor.description is not None:
        result = cursor.fetchall()
    else:
        result = None

    cursor.close()
    connection.close()

    return result

#Send SMS Using textlocal api
def sendSMS(apikey, numbers, sender, message):
    data =  urllib.parse.urlencode({'apikey': apikey, 'numbers': numbers,
        'message' : message, 'sender': sender})
    data = data.encode('utf-8')
    request = urllib.request.Request("https://api.textlocal.in/send/?")
    f = urllib.request.urlopen(request, data)
    fr = f.read()
    return(fr)

#Generate OTP
def generate_otp_helper():
    return str(random.randint(1000, 9999))

def generate_otp_echo(otp):
    return jsonify({'otp': otp})

# Check if the number exists in the database take two parameter number and the table we have to look into.
def check_number_in_database(number,person):
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()

    query = "SELECT * FROM {} WHERE phonenumber = %s;".format(person)
    cursor.execute(query, (number,))
    result = cursor.fetchone()

    cursor.close()
    conn.close()

    return result is not None


# API endpoints



# Add User Information
@app.route('/users', methods=['POST'])
def handle_users():
    data = request.json
    name = data['name']
    phoneNumber = data['phoneNumber']
    dateOfBirth = data['dateOfBirth']
    gender = data['gender']
    city = data['city']
    medicalCondition = data['medicalCondition']
    familyHistory = data['familyHistory']
    bloodGroup = data['bloodGroup']
    status = data['status']
    doctorid = data['doctorid']

    # Decode base64 image
    base64_image = data['image']
    image_data = base64.b64decode(base64_image)

    # # Save the image to a file or process it as needed
    # with open(f'{name}_profile_pic.png', 'wb') as f:
    #     f.write(image_data)

    # Your code to insert user information into the database or perform other operations
    query = "INSERT INTO userinfo (name, phoneNumber, dateOfBirth, gender, city, medicalCondition, familyHistory, bloodGroup, status, doctorid,profilepic) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s,%s);"
    params = (
        name,
        phoneNumber,
        dateOfBirth,
        gender,
        city,
        medicalCondition,
        familyHistory,
        bloodGroup,
        status,
        doctorid,
        image_data
    )

    # Your code to execute the query and insert data into the database
    execute_query(query, params)

    return jsonify({'message': 'User information created successfully.'}), 201


# Get User by phoneNumber
@app.route('/get_users/<string:phoneNumber>', methods=['GET'])
def get_user_by_phoneNumber(phoneNumber):
    try:
        # Connect to the PostgreSQL database
        connection = psycopg2.connect(**db_config)
        cursor = connection.cursor()

        # Execute the SQL query to fetch data for the given user_name from the "users" table
        cursor.execute('SELECT name, phoneNumber,dateOfBirth,gender, city, medicalCondition, familyHistory, bloodGroup, status, doctorid,profilepic  FROM userinfo WHERE phoneNumber = %s', (phoneNumber,))
        
        # Fetch the row from the result set
        row = cursor.fetchone()
        # print(row);

        # Close the cursor and the database connection
        cursor.close()
        connection.close()

        if row:
            # Convert the row to a dictionary
            user = {
                'name': row[0],
                'phoneNumber': row[1],
                'dateOfBirth': row[2],
                'gender': row[3],
                'city': row[4],
                'medicalCondition': row[5],
                'familyHistory': row[6],
                'bloodGroup': row[7],
                'status': row[8],
                'doctorid': row[9],
                'profilepic': base64.b64encode(row[10]).decode('utf-8'),
            }

            # Return the JSON response with the user data
            return jsonify(user)
        else:
            # Return a 404 response if the user_name does not exist in the database
            return jsonify({'message': 'User not found'}), 404

    except psycopg2.Error as e:
        # Handle any errors that might occur during the database query
        return jsonify({'error': str(e)}), 500


#Get Approved Patients or where the status == 1 
@app.route('/approved_patients/<string:doctor_id>', methods=['GET'])
def get_approved_patients_by_doctor(doctor_id):
    try:
        connection = psycopg2.connect(**db_config)
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM userinfo WHERE doctorid = %s AND status = 1", (doctor_id,))
        patients_data = cursor.fetchall()
        cursor.close()
        connection.close()
        patients_list = []
        for patient in patients_data:
            patient_dict = {
                'name': patient[0],
                'phoneNumber': patient[1],
                'dateOfBirth': patient[2],
                'gender': patient[3],
                'city': patient[4],
                'medicalCondition': patient[5],
                'familyHistory': patient[6],
                'bloodGroup': patient[7],
                'status': patient[8],
                'doctorid': patient[9],
            }
            patients_list.append(patient_dict)
        return jsonify(patients_list)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# Get Pending Patients where status == 0
@app.route('/pending_patients/<string:doctor_id>', methods=['GET'])
def get_pending_patients_by_doctor(doctor_id):
    try:
        connection = psycopg2.connect(**db_config)
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM userinfo WHERE doctorid = %s AND status = 0", (doctor_id,))
        patients_data = cursor.fetchall()
        cursor.close()
        connection.close()
        patients_list = []
        for patient in patients_data:
            patient_dict = {
                'name': patient[0],
                'phoneNumber': patient[1],
                'dateOfBirth': patient[2],
                'gender': patient[3],
                'city': patient[4],
                'medicalCondition': patient[5],
                'familyHistory': patient[6],
                'bloodGroup': patient[7],
                'status': patient[8],
                'doctorid': patient[9],
            }
            patients_list.append(patient_dict)
        return jsonify(patients_list)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


#Update Profile User
@app.route('/update_profile', methods=['POST'])
def update_profile():
    try:
        
        data = request.get_json()
        phone_number = data.get('phone_number')
        base64_image = data['image']
        image_data = base64.b64decode(base64_image)

        if not phone_number:
            return jsonify({'error': 'Phone number not provided'}), 400

        connection = psycopg2.connect(**db_config)
        cursor = connection.cursor()

        # Update the status to 1 for the given phone number
        cursor.execute("UPDATE userinfo SET profilepic = %s  WHERE phoneNumber = %s", (image_data, phone_number))
        connection.commit()

        cursor.close()
        connection.close()

        return jsonify({'message': 'Pic updated successfully'})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


#Update the status to 1 (Approved)
@app.route('/update_status1', methods=['POST'])
def update_status1():
    try:
        data = request.get_json()
        phone_number = data.get('phone_number')

        if not phone_number:
            return jsonify({'error': 'Phone number not provided'}), 400

        connection = psycopg2.connect(**db_config)
        cursor = connection.cursor()

        # Update the status to 1 for the given phone number
        cursor.execute("UPDATE userinfo SET status = 1 WHERE phoneNumber = %s", (phone_number,))
        connection.commit()

        cursor.close()
        connection.close()

        return jsonify({'message': 'Status updated successfully'})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


#Update the status to 2 (Rejected)
@app.route('/update_status2', methods=['POST'])
def update_status2():
    try:
        data = request.get_json()
        phone_number = data.get('phone_number')

        if not phone_number:
            return jsonify({'error': 'Phone number not provided'}), 400

        connection = psycopg2.connect(**db_config)
        cursor = connection.cursor()

        # Update the status to 2 for the given phone number
        cursor.execute("UPDATE userinfo SET status = 2 WHERE phoneNumber = %s", (phone_number,))
        connection.commit()

        cursor.close()
        connection.close()

        return jsonify({'message': 'Status updated successfully'})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


#Change the doctor for a user and set status to 0 (Pending)
@app.route('/edit_doctor', methods=['POST'])
def edit_doctor():
    try:
        
        data = request.get_json()
        phone_number = data.get('phoneNumber')
        email = data.get('doctorid')

        print(email)

        if not phone_number:
            return jsonify({'error': 'Phone number not provided'}), 400

        connection = psycopg2.connect(**db_config)
        cursor = connection.cursor()

        # Update the status to 1 for the given phone number
        cursor.execute("UPDATE userinfo SET doctorid = %s, status = 0 WHERE phoneNumber = %s", (email, phone_number))
        connection.commit()

        cursor.close()
        connection.close()

        return jsonify({'message': 'updated successfully'})

    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Get Doctors List 
@app.route('/get_doctors')
def get_doctors():
    try:
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute('SELECT name, email, hospitalName , city FROM doctors;')
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        doctors = []
        for row in rows:
            doctor = {
                'name': row[0],
                'email': row[1],
                'hospitalName': row[2],
                'city': row[3],
            }
            doctors.append(doctor)

        return jsonify({'doctors': doctors})
    except Exception as e:
        return jsonify({'error': str(e)})


# Get Doctor from phoneNumber
@app.route('/get_doctors_by_number/<string:phoneNumber>', methods=['GET'])
def get_doctors_by_phoneNumber(phoneNumber):
    try:
        # Connect to the PostgreSQL database
        connection = psycopg2.connect(**db_config)
        cursor = connection.cursor()

        # Execute the SQL query to fetch data for the given user_name from the "users" table
        cursor.execute('SELECT name,email,phonenumber,hospitalname, city ,otp FROM doctors WHERE phoneNumber = %s', (phoneNumber,))
        
        # Fetch the row from the result set
        row = cursor.fetchone()
        # print(row);

        # Close the cursor and the database connection
        cursor.close()
        connection.close()

        if row:
            # Convert the row to a dictionary
            user = {
                'name': row[0],
                'email': row[1],
                'phonenumber': row[2],
                'hospitalname': row[3],
                'city': row[4],
                'otp' : row[5],
            }

            # Return the JSON response with the user data
            return jsonify(user)
        else:
            # Return a 404 response if the user_name does not exist in the database
            return jsonify({'message': 'User not found'}), 404

    except psycopg2.Error as e:
        # Handle any errors that might occur during the database query
        return jsonify({'error': str(e)}), 500


#Generate OTP
@app.route('/generateOtp',methods=['POST'])
def generateOtp():
    try:
        data = request.json
        number = data.get('numbers')
        print(f'Mobile Number: {number}')
    except Exception as e:
        return jsonify({'error': 'Invalid JSON data'}), 400

    otp = generate_otp_helper() 
    print(otp)
    return otp;

#Check Number in the database
@app.route("/check_number", methods=["POST"])
def check_number():
    data = request.get_json()
    number_to_check = data.get("number")

    if not number_to_check:
        return jsonify({"message": "Invalid request. 'number' field is missing."}), 400

    exists = check_number_in_database(number_to_check,"doctors")
    return jsonify({"exists": exists})


@app.route("/check_number_first_time", methods=["POST"])
def check_number_first_time():
    data = request.get_json()
    number_to_check = data.get("number")

    if not number_to_check:
        return jsonify({"message": "Invalid request. 'number' field is missing."}), 400

    exists = check_number_in_database(number_to_check,"userinfo")
    return jsonify({"exists": exists})

#Add Blood Sugar Records
@app.route('/save_blood_sugar', methods=['POST'])
def save_blood_sugar():
    data = request.json
    query = "INSERT INTO blood_sugar_records (date,time,meal_type,blood_sugar,phoneNumber) VALUES (%s, %s,%s,%s,%s);"
    params = (
            data['selectedDate'],
            data['selectedTime'],
            data['mealType'],
            data['bloodSugar'],
            data['phoneNumber'],
    )
    execute_query(query, params)
    return jsonify({'message': 'User information created successfully.'}), 201

#Get Blood Sugars records by phoneNumber
@app.route('/blood_sugar_records/<string:phoneNumber>', methods=['GET'])
def get_blood_sugar_records(phoneNumber):
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()

    # Assuming your BloodSugarRecord table exists and matches the columns mentioned
    cursor.execute('SELECT date, time, meal_type, blood_sugar FROM blood_sugar_records WHERE phoneNumber = %s', (phoneNumber,))
    records = cursor.fetchall()

    conn.close()

    # Convert the data into a list of dictionaries
    data = []
    for record in records:
        data.append({
            'date': str(record[0]),
            'time': str(record[1]),
            'meal_type': record[2],
            'blood_sugar': record[3]
        })

    return jsonify(data)

#Get insulin records records by phoneNumber
@app.route('/insulin_records/<string:phoneNumber>', methods=['GET'])
def get_insulin_records(phoneNumber):
    
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()

    # Assuming your BloodSugarRecord table exists and matches the columns mentioned
    cursor.execute('SELECT date, time, meal_type, insulin FROM insulin_records WHERE phoneNumber = %s', (phoneNumber,))
    records = cursor.fetchall()

    conn.close()

    # Convert the data into a list of dictionaries
    data = []
    for record in records:
        data.append({
            'date': str(record[0]),
            'time': str(record[1]),
            'meal_type': record[2],
            'insulin': record[3]
        })

    return jsonify(data)

#Get activity records by phoneNumber
@app.route('/activity_records/<string:phoneNumber>', methods=['GET'])
def get_activity_records(phoneNumber):
    
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()

    # Assuming your BloodSugarRecord table exists and matches the columns mentioned
    cursor.execute('SELECT date, time, activity_type FROM activity_records WHERE phoneNumber = %s', (phoneNumber,))
    records = cursor.fetchall()

    conn.close()

    # Convert the data into a list of dictionaries
    data = []
    for record in records:
        data.append({
            'date': str(record[0]),
            'time': str(record[1]),
            'activity_type': record[2]
        })

    return jsonify(data)

#Get Blood reports records by phoneNumber
@app.route('/blood_reports/<string:phoneNumber>', methods=['GET'])
def get_blood_reports(phoneNumber):
    
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()

    # Assuming your BloodSugarRecord table exists and matches the columns mentioned
    cursor.execute('SELECT * FROM blood_reports WHERE phoneNumber = %s', (phoneNumber,))
    records = cursor.fetchall()

    conn.close()

    # Convert the data into a list of dictionaries
    data = []
    for record in records:
        data.append({
            'phonenumber': str(record[0]),
            'date': str(record[1]),
            'time': str(record[2]),
            'hba1c': record[3],
            'cholesterol': record[4],
            'vitamind': record[5],
            'vitaminb12': record[6],
        })

    return jsonify(data)

#Get meal intake records by phoneNumber
@app.route('/get_mealIntake/<string:phoneNumber>', methods=['GET'])
def get_mealIntake(phoneNumber):
        
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()

    # Assuming your BloodSugarRecord table exists and matches the columns mentioned
    cursor.execute('SELECT date,time,meal_intake FROM meal_records WHERE phoneNumber = %s', (phoneNumber,))
    records = cursor.fetchall()

    conn.close()

    # Convert the data into a list of dictionaries
    data = []
    for row in records:
        data.append({
            'date': str(row[0]),
            'time': str(row[1]),
            'meal_intake': row[2],
        })

    return jsonify(data)

#Get foodpic records by phoneNumber
@app.route('/get_foodpic/<string:date>/<string:time>/<string:phoneNumber>', methods=['GET'])
def get_foodpic(phoneNumber,date,time):
    
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()
    
    # Assuming your BloodSugarRecord table exists and matches the columns mentioned
    cursor.execute('SELECT food_pics FROM meal_records WHERE phoneNumber = %s AND date = %s AND time = %s', (phoneNumber, date, time))
    row = cursor.fetchone()

    conn.close()

    # Convert the data into a list of dictionaries
    if row:
        # Convert the row to a dictionary
        data = {
                'foodpic': base64.b64encode(row[0]).decode('utf-8'),     
        }
    else:
        # Return a 404 response if the user_name does not exist in the database
        return jsonify({'message': 'User not found'}), 404
    return jsonify(data)

# Add insulin records
@app.route('/save_insulin', methods=['POST'])
def save_insulin():
    data = request.json
    query = "INSERT INTO insulin_records (date,time,meal_type, insulin,phoneNumber) VALUES (%s, %s,%s,%s,%s);"
    params = (
            data['selectedDate'],
            data['selectedTime'],
            data['mealType'],
            data['insulin'],
            data['phoneNumber'],
    )
    execute_query(query, params)
    return jsonify({'message': 'User information created successfully.'}), 201

# Add meal-intake records
@app.route('/save_mealIntake', methods=['POST'])
def save_mealIntake():
    data = request.json

    # Decode base64 image
    base64_image = data['foodpic']
    image_data = base64.b64decode(base64_image)

    # Your code to insert user information into the database or perform other operations
    query = "INSERT INTO meal_records (date,time,meal_intake,phoneNumber,food_pics) VALUES (%s, %s,%s,%s,%s);"
    params = (
        data['selectedDate'],
        data['selectedTime'],
        data['mealType'],
        data['phoneNumber'],
        image_data
    )

    # Your code to execute the query and insert data into the database
    execute_query(query, params)

    return jsonify({'message': 'User information created successfully.'}), 201

# Add activity records
@app.route('/save_activity', methods=['POST'])
def save_activity():
    data = request.json
    query = "INSERT INTO activity_records (date,time,activity_type,phoneNumber) VALUES (%s, %s,%s,%s);"
    params = (
            data['selectedDate'],
            data['selectedTime'],
            data['activityType'],
            data['phoneNumber'],
    )
    execute_query(query, params)
    return jsonify({'message': 'User information created successfully.'}), 201

# Add blood reports records
@app.route('/save_blood_reports', methods=['POST'])
def save_blood_reports():
    data = request.json
    query = "INSERT INTO blood_reports (phoneNumber,date,time,hba1c,cholesterol,vitaminD,vitaminB12) VALUES (%s, %s,%s,%s,%s,%s,%s);"
    params = (
            data['phoneNumber'],
            data['selectedDate'],
            data['selectedTime'],
            data['hba1c'],
            data['cholesterol'],
            data['vitaminD'],
            data['vitaminB12'],
    )
    execute_query(query, params)
    return jsonify({'message': 'User information created successfully.'}), 201


if __name__ == '__main__':
    app.run()



#Using TestlocalAPI to send SMS OTP
# @app.route('/sendsms', methods=['POST'])
# def sendsms():
#     try:
#         data = request.json
#         numbers = data.get('numbers')
#     except Exception as e:
#         return jsonify({'error': 'Invalid JSON data'}), 400
    
#     apikey = " "
#     sender = "600010"
#     otp = generate_otp()
#     generate_otp_echo(otp);
#     print(otp)
#     message = f"Hi there, thank you for sending your first test message from Textlocal. Get 20% off today with our code: {otp}."
#     print(message)
#     if not all([apikey, numbers, sender, message]):
#         return jsonify({'error': 'Missing data'}), 400

#     response = sendSMS(apikey, numbers, sender, message)
#     return otp
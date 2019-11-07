import os
import glob
import xml.etree.ElementTree as ET
import re

# Schema for xml temparing	
schema = "{urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2}"
schema_id = "{urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2}"

# Variables to store the extracted order information
contact_final = []
address_final = []
order_id = []


# Getting latest file name to Parse
def get_latest_file_name():
	files = glob.glob('./xml/*.xml')
	return max(files, key=os.path.getctime)


# Load the file name in a variable
xml_file = get_latest_file_name()


# Reading the File
def load_xml(arg):
	with open(arg, 'r') as file:
		return file.read()


# Function for to extract ID, Contact & Delivery
def parse_xml():
	root = ET.fromstring(load_xml(xml_file))

	# Get Order ID
	get_id = root.find("{}ID".format(schema_id))
	order_id.append(get_id.text)
		
	# Get Delivery			
	for get_delivery in root.find("{}Delivery".format(schema)):
		for elem in list(get_delivery.itertext()):
			if re.match("[ a-zA-Z0-9 ]", elem):
				address_final.append(elem)

	# Get Customer information
	for customer in root.find("{}AccountingCustomerParty".format(schema)):
		for contact in list(customer.iterfind("{}Contact".format(schema))):
			for the_contact in list(contact.itertext()):
				if re.match("[ a-zA-Z0-9 ]", the_contact):
					contact_final.append(the_contact)			
	write_xml()



# Function to write the parced xml file
def write_xml():

	# XML Fields Names
	address_fields = ["Address", "City", "Postcode", "Country"]
	contact_fields = ["Name", "Phone", "Email"]

	# Root of XML

	data = ET.Element("data")
	data = ET.SubElement(data, "data")

	# Write Order ID

	id_details = ET.SubElement(data, "ID")
	id_details.text = str(order_id[0])

	# Write Order Contact

	for i in range(len(contact_final)):
		person_details = ET.SubElement(data, contact_fields[i])
		person_details.text = str(contact_final[i])

	# Write Order Address

	for i in range(len(address_final)):
		address = ET.SubElement(data, address_fields[i])
		address.text = str(address_final[i])

	# Write to file

	tree = ET.ElementTree(data)
	tree.write("order_{}.xml".format(order_id[0]),encoding="utf-8", xml_declaration=True)


parse_xml()
import yaml

with open('file.yml', 'r') as file:
    data = yaml.safe_load(file)

# for i in range(len(data)):
#     print(f"Item: {data[i]['item']} | Value: {
#           data[i]['value']} | Desc: {data[i]['desc']}")

with open('names.yml', 'w') as file:
    yaml.dump(data, file)

print(open('names.yml').read())

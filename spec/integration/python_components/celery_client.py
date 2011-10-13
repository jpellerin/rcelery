from tasks import multiply

result = multiply.delay(5,4)
print result.get(4)


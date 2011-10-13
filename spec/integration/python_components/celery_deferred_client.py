from datetime import datetime

from tasks import multiply

now = datetime.now()
run_at = now.replace(second = (now.second + 5) % 60)

result = multiply.apply_async(args=[5,5], eta=run_at)
print result.get(10)


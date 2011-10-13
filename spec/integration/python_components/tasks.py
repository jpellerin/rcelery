import time

from celery.task import task


@task(name='r_celery.integration.add')
def add(a, b):
    return a + b

@task(name='r_celery.integration.multiply')
def multiply(a, b):
    return a * b


from os import environ

BROKER_HOST = environ.get('RCELERY_HOST', "localhost")
BROKER_PORT = environ.get('RCELERY_PORT', 5672)
BROKER_USER = environ.get('RCELERY_USERNAME', "guest")
BROKER_PASSWORD = environ.get('RCELERY_PASSWORD', "guest")
BROKER_VHOST = environ.get('RCELERY_VHOST', "/integration")

CELERY_RESULT_BACKEND = "amqp"
CELERY_RESULT_PERSISTENT = True

CELERY_QUEUES = {
    "rcelery.integration": {"exchange": "celery",
                            "routing_key": "rcelery.integration"},
    "rcelery.python.integration": {"exchange": "celery",
                            "routing_key": "rcelery.python.integration"}
}

CELERY_DEFAULT_QUEUE = "rcelery.integration"

CELERY_RESULT_SERIALIZER = "json"
CELERY_TASK_SERIALIZER = "json"
CELERY_AMQP_TASK_RESULT_EXPIRES = 3600

CELERY_IMPORTS = ("tasks", )
CELERY_SEND_EVENTS = True

import pika
import time
import queue

class rabbit():
    def __init__(self, host, credentials, que):
        self.credentials = pika.PlainCredentials(*credentials)
        self.params = pika.ConnectionParameters(host=host, credentials=self.credentials)
        self.que = que
        self.connection = pika.BlockingConnection(self.params)
        self.channel = self.connection.channel()
        # self.channel.queue_declare(queue=self.que)

    def create_que(self):
        self.channel.queue_declare(queue=self.que)

    def get_message(self):
        return self.channel.basic_get(self.que)

    def send_message(self, mess):
        self.channel.basic_publish(exchange='', routing_key=self.que, body=mess)

    def ack_message(self, method):
        self.channel.basic_ack(method.delivery_tag)

    def listen(self, in_que):
        while True:
            mess = self.channel.basic_get(self.que)
            if mess[0]:
                in_que.put(mess)
            time.sleep(0.1)

# rab = rabbit([], ['guest', 'guest'], 'lighthouse-etl')
# rab.create_que()
# rab.send_message('hello')
# out = rab.get_message()
# rab.ack_message(out[0])
# rab.listen(queue.Queue())

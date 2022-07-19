import pika
import time
import queue
import threading

class rabbit():
    def __init__(self, host, credentials, que):
        self.credentials = pika.PlainCredentials(*credentials)
        self.params = pika.ConnectionParameters(host=host, credentials=self.credentials)
        self.que = que
        self.connection = pika.BlockingConnection(self.params)
        self.channel = self.connection.channel()
        self.lock = threading.Lock()
        # self.channel.queue_declare(queue=self.que)

    def create_que(self):
        self.lock.acquire()
        self.channel.queue_declare(queue=self.que)
        self.lock.release()

    def get_message(self):
        self.lock.acquire()
        mess = self.channel.basic_get(self.que)
        self.lock.release()
        return mess

    def send_message(self, mess):
        self.lock.acquire()
        self.channel.basic_publish(exchange='', routing_key=self.que, body=mess)
        self.lock.release()

    def ack_message(self, method):
        self.lock.acquire()
        self.channel.basic_ack(method.delivery_tag)
        self.lock.release()

    def listen(self, in_que):
        while True:
            self.lock.acquire()
            mess = self.channel.basic_get(self.que)
            self.lock.release()
            if mess[0]:
                in_que.put(mess)
            time.sleep(0.1)

# rab = rabbit([], ['guest', 'guest'], 'lighthouse-etl')
# rab.create_que()
# rab.send_message('hello')
# out = rab.get_message()
# rab.ack_message(out[0])
# rab.listen(queue.Queue())

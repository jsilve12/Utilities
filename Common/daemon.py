""" Abstract Daemon Class """
import time
import queue
import threading
from rabbit import rabbit
from functools import partial
from multiprocessing.pool import ThreadPool

class Daemon():
    def __init__(self, que, map_func, out_func):
        self.func = map_func
        self.in_que = queue.Queue()
        self.map_func = map_func
        self.out_que = queue.Queue()
        self.out_func = out_func
        self.rabbit = rabbit([], ['guest', 'guest'], que)


    def listen(self):
        listen_thread = threading.Thread(target = self.rabbit.listen, args = (self.in_que,))
        listen_thread.start()
        for i in range(7):
            run_thread = threading.Thread(target = self.map_func, args = (self.in_que, self.out_que, self.rabbit ))
            run_thread.start()
        out_thread = threading.Thread(target = self.out_func, args = (self.out_que, ))
        listen_thread.join()

def temp_func(inq, outq, rabbit):
    while True:
        mess = inq.get()
        rabbit.ack_message(mess[0])
        print(mess)
        time.sleep(0.1)

# d = Daemon('lighthouse-etl', temp_func, lambda x: x)
# d.listen()

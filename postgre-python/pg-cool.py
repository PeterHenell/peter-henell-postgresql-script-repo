#!/usr/bin/python
# -*- coding: utf-8 -*-

import psycopg2
import sys
from multiprocessing import Process

cars = (
    ('Audi', 52642),
    ('Mercedes', 57127),
    ('Skoda', 9000),
    ('Volvo', 29000),
    ('Bentley', 350000),
    ('Citroen', 21000),
    ('Hummer', 41400),
    ('Volkswagen', 21600)
)

def insertBunch(a):
    try:
        con = None
        con = psycopg2.connect(database='MppPOC', user='postgres', password='hemligt')
        cur = con.cursor()

       # cur.execute("DROP TABLE IF EXISTS cars")
        cur.execute("CREATE TABLE IF NOT EXISTS cars(id serial PRIMARY KEY, name TEXT, price INT)")
        query = "INSERT INTO cars (name, price) VALUES (%s, %s)"
        cur.executemany(query, cars)

        con.commit()

    except psycopg2.DatabaseError as e:
        print('Error %s' % e)
        sys.exit(1)


    finally:

        if con:
            con.close()


if __name__ == '__main__':
    for u in range(1, 10) :
        p = Process(target=insertBunch, args=('bob',))
        p.start()
        #p.join()
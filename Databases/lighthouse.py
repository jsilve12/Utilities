""" Utilities for dealing with the database """


import time
import json
import psycopg2


CONN = psycopg2.connect(host='34.132.46.144', user='postgres', password=f"Fk1VmpqWGpWdVk")


def create_pipeline(name, cron):
    with CONN.cursor() as cursor:
        cursor.execute(
            "INSERT INTO pipeline(name, cron) VALUES(%s, %s) ON CONFLICT(name) DO UPDATE SET name=%s RETURNING id",
            (name, cron, name)
        )
        id = cursor.fetchall()[0][0]
        cursor.execute("COMMIT;")
        return id


def create_job(id, job):
    with CONN.cursor() as cursor:
        cursor.execute(
            "INSERT INTO job(name, pipeline, job_type, method, base_url, url_method) VALUES(%s, %s, (SELECT id FROM c_job WHERE name=%s), (SELECT id FROM c_method WHERE name=%s), %s, %s) ON CONFLICT(name, pipeline) DO UPDATE SET name=%s RETURNING id",
            (job['name'], id, job['type'], job['method'], job['urls']['base'], job['urls'].get('method', 'get'), job['name'])
        )
        id = cursor.fetchall()[0][0]
        for key, value in job['urls'].get('variables', {}).items():
            cursor.execute(
                "INSERT INTO variables(job, name, var_type, format, start, final) VALUES(%s, %s, (SELECT id FROM c_variables WHERE name=%s), %s, %s, %s) ON CONFLICT DO NOTHING",
                (id, key, value.get('type', ''), value.get('format', ''), value.get('start', ''), value.get('end'))
            )
            if value.get('type') == 'string':
                for v in value.get('values'):
                    cursor.execute("INSERT INTO var_values(var, value) VALUES((SELECT id FROM variables WHERE name=%s LIMIT 1), %s)", (key, v))
        for depends in job['depends_on']:
            cursor.execute("INSERT INTO depends(job, depends) VALUES(%s, (SELECT id FROM job WHERE name=%s))", (id, depends))
        cursor.execute("COMMIT;")


def get_jobs(cursor):
    cursor.execute('SELECT * FROM job JOIN pipeline ON pipeline.id=job.pipeline')
    return cursor.fetchall()


def get_dependencies(cursor, job_id):
    cursor.execute('SELECT DISTINCT(depends) FROM depends WHERE job=%s', (job_id,))
    return cursor.fetchall()


def get_tracking(cursor, job_id):
    cursor.execute('SELECT * FROM tracking WHERE job=%s ORDER BY occured DESC', (job_id, ))
    return cursor.fetchall()


def get_variables(cursor, job_id):
    cursor.execute('SELECT * FROM variables JOIN c_variables AS c_var ON variables.var_type = c_var.id WHERE job=%s', (job_id, ))
    return cursor.fetchall()


def get_variable_values(cursor, variable_id):
    cursor.execute('SELECT value FROM var_values WHERE var=%s', (variable_id,))
    return cursor.fetchall()


def insert_tracking(track_id, job_id):
    with CONN.cursor() as cursor:
        cursor.execute(f"INSERT INTO tracking(job, id) VALUES{','.join(['(%s, %s)' for i in track_id])}; COMMIT;", [i for j in track_id for i in [job_id, j]])

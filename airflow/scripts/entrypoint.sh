#!/usr/bin/env bash
airflow db init

airflow users create \
    --username junoha \
    --password Admadm10 \
    --firstname Jun \
    --lastname Ohashi \
    --role Admin \
    --email jun.ohashi.42@gmail.com

airflow webserver
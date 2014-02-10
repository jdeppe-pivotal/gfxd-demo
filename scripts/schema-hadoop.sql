-- DROPs in order
DROP table if exists load_averages;
DROP table if exists raw_sensor;
DROP HDFSSTORE IF EXISTS sensorStore;


-- CREATES in order
create table load_averages
  (
    house_id integer not null,
    household_id integer,
    plug_id integer not null,
    weekday smallint not null,
    time_slice smallint not null,
    total_load float(23),
    event_count integer

  )
  partition by column (house_id)
  colocate with (raw_sensor);

alter table load_averages
    add constraint LOAD_AVERAGES_PK PRIMARY KEY (house_id, plug_id, weekday, time_slice);

DROP index if exists load_averages_idx;
create index load_averages_idx on load_averages (weekday, time_slice, plug_id);


CREATE HDFSSTORE sensorStore
  NameNode 'hdfs://localhost:9000'
  HomeDir '/sensorStore'
  BatchSize 10
  BatchTimeInterval 2000;

create table raw_sensor
  (
    id bigint,
    timestamp bigint,
    value float(23),
    property smallint,
    plug_id integer,
    household_id integer,
    house_id integer,
    weekday smallint,
    time_slice smallint
  )
  partition by column (house_id)
  persistent
  hdfsstore (sensorStore);

DROP index if exists raw_sensor_idx;
create index raw_sensor_idx on raw_sensor (weekday, time_slice, plug_id);

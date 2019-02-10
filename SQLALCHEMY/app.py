import numpy as np
import pandas as pd
import datetime as dt

import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, func, distinct

from flask import Flask, jsonify

#################################################
# Database Setup
#################################################
engine = create_engine("sqlite:///hawaii.sqlite")

Base = automap_base()

Base.prepare(engine, reflect=True)

# Save reference to the table
Measurement = Base.classes.measurement
Station = Base.classes.station

# Create our session (link) from Python to the DB
session = Session(engine)

app = Flask(__name__)

# Query for the dates and temperature observations from the last year.
# Convert the query results to a Dictionary using date as the key and tobs as the value.
# Return the JSON representation of your dictionary.
@app.route("/api/v1.0/precipitation")

def prcp():
    year = dt.datetime(2016, 8, 23)
    result = session.query(Measurement.date, Measurement.prcp).filter(Measurement.date > year).all()

    lastyear = []
    for i in result:
        ly = {}
        ly['date'] = i.date
        ly['prcp'] = i.prcp
        lastyear.append(ly)
    return jsonify(lastyear)

# Return a JSON list of stations from the dataset.
@app.route("/api/v1.0/stations")

def stations():
    result = session.query(distinct(Measurement.station)).all()
    station = list(np.ravel(result))

    return jsonify(station)

# Return a JSON list of Temperature Observations (tobs) for the previous year.
@app.route("/api/v1.0/tobs")

def tobs():
    year = dt.datetime(2016, 8, 23)
    result = list(np.ravel(session.query(Measurement.prcp).filter(Measurement.date > year).all()))

    return jsonify(result)

# Return a JSON list of the minimum temperature, the average temperature, and the max temperature for a given start or start-end range.
# When given the start only, calculate TMIN, TAVG, and TMAX for all dates greater than and equal to the start date.
# When given the start and the end date, calculate the TMIN, TAVG, and TMAX for dates between the start and end date inclusive.

@app.route("/api/v1.0/<start>")

def start(start):
    result = list(session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).\
        filter(Measurement.date >= start).all()[0])
    

    return jsonify(result)


@app.route("/api/v1.0/<start>/<end>")

def startend(start_date, end_date):
    result = list(session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).\
        filter(Measurement.date >= start_date).filter(Measurement.date <= end_date).all()[0])
    return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True)

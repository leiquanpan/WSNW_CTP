import sys
from PyQt5.QtWidgets import QApplication, QWidget, QMainWindow, QPushButton, QLineEdit
from PyQt5.QtWidgets import QLabel, QInputDialog, QSizePolicy, QComboBox, QVBoxLayout, QSizePolicy
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import pyqtSlot
import boto3
import json
import time
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import random


class MyMplCanvas(FigureCanvas):
    """Ultimately, this is a QWidget (as well as a FigureCanvasAgg, etc.)."""

    def __init__(self, parent=None, width=200, height=300, dpi=100):
        fig = Figure(figsize=(width, height), dpi=dpi)
        self.axes = fig.add_subplot(111)

        self.compute_initial_figure()

        FigureCanvas.__init__(self, fig)
        self.setParent(parent)

        FigureCanvas.setSizePolicy(self,
                                   QSizePolicy.Expanding,
                                   QSizePolicy.Expanding)
        FigureCanvas.updateGeometry(self)

    def compute_initial_figure(self):
        pass


class MyStaticMplCanvas(MyMplCanvas):
    """Simple canvas with a sine plot."""

    def compute_initial_figure(self):
        t = np.arange(0.0, 3.0, 0.01)
        s = np.sin(2*np.pi*t)
        self.axes.plot(t, s)

class App(QMainWindow):
 
    def __init__(self):
        super().__init__()
        self.title = 'Sample UI version 1.0 -- CSPL'
        self.left = 10
        self.top = 10
        self.width = 600
        self.height = 600
        self.initUI()

 
    def initUI(self):
        self.setWindowTitle(self.title)
        self.setGeometry(self.left, self.top, self.width, self.height)
        button = QPushButton('Start', self)
        button.setToolTip('This is an example button')
        button.move(250,45)
        # Create textbox
        label1 = QLabel('End Time:', self)
        label1.move(5,45)
        label2 = QLabel('Start Time:', self)
        label2.move(5,15)
        label3 = QLabel('Sensor Id:', self)
        label3.move(5,75)

        self.textbox2 = QLineEdit(self)
        self.textbox2.move(70, 20)
        self.textbox2.resize(140,20)

        self.textbox = QLineEdit(self)
        self.textbox.move(70, 50)
        self.textbox.resize(140,20)

        self.textbox3 = QLineEdit(self)
        self.textbox3.move(70, 80)
        self.textbox3.resize(140,20)

        self.statusBar().showMessage('WUSTL CSPL')
        button.clicked.connect(self.on_click)
        self.option = 0

        self.combo = QComboBox(self)
        self.combo.addItem("Temperature Distribution")
        self.combo.addItem("Average Temperature")
        self.combo.addItem("Latest Temperature")
        self.combo.move(250, 15)
        self.combo.activated.connect(self.onActivated)

        self.m = PlotCanvas(self, width=13, height=10, dpi=100, x_data=[], y_data=[])
        self.m.move(0, 110)



        '''
        self.main_widget = QWidget(self)
        l = QVBoxLayout(self.main_widget)
        sc = MyStaticMplCanvas(self.main_widget, width=200, height=300, dpi=100)
        l.addWidget(sc)
        '''
        self.show()
    '''
    def getChoice(self):
        items = ("option","Compute Average for a Sensor")
        item, okPressed = QInputDialog.getItem(self, "Get item","Option:", items, 0, False)
        if ok and item:
            if item == "option":
                self.option = 0
            if item == "Compute Average for a Sensor":
                self.option = 1
    '''

    def onActivated(self, index):
        print(index)
        if index == 0:
            self.option = 0
        if index == 1:
            self.option = 1



    @pyqtSlot()
    def on_click(self):
        sensor_num = self.textbox3.text().split(',')
        
        
        
        
        
        
        
        
#        start_time = int(self.textbox2.text())
#        end_time = int(self.textbox.text())
        #start_time = self.textbox2.text()
        #end_time = self.textbox.text()
        start = time.strptime(self.textbox2.text(), "%Y-%m-%d %H:%M:%S")
        end = time.strptime(self.textbox.text(), "%Y-%m-%d %H:%M:%S")
        time_start = str(int(time.mktime(start)) * 1000)
        time_end = str(int(time.mktime(end)) * 1000)
        client = boto3.client('dynamodb',region_name='us-west-2',aws_access_key_id='AKIAI4V7PJJGQ******',aws_secret_access_key='69a/sfegtKXMHbVreSHFW*********')
        response = client.query(
            TableName='Sensor_data',
            #   Select='ALL_ATTRIBUTES',
            KeyConditionExpression= 'Sensor_ID = :a and Date_time > :b and Date_time < :c',
            ExpressionAttributeValues= {
                ':a': {
                    'S':'sensor_01'
                },
                ':b': {
                    'S': time_start
                },
                ':c': {
                    'S': time_end
                }
            }
        )
        Time_num = []
        Temp_num = []
        things = response['Items']
        #print things
        if self.option == 0:
            for thing in things:
                payload = thing['payload']
                M = payload['M']
                sensor_id = M['sensorId']
                timestamp = M['timeStamp']
                time_temp = int(timestamp['N'])
#                if (sensor_id['N'] == sensor_num) and (time_temp >= start_time) and (time_temp <= end_time):
                if sensor_id['N'] == sensor_num:
                    Time_num.append(time_temp)
                    temperature = M['temp']
                    Temp_num.append(temperature['N'])
            temp_N = np.array(Temp_num, dtype=np.float32)
            Time_num = np.array(Time_num) - Time_num[0]

            self.m.setXY(Time_num, temp_N)
            self.m.plot()
            '''
            plt.scatter(Time_num, temp_N, s=10, c='b', marker="s")
            plt.autoscale()
            plt.show()
            '''

        if self.option == 1:
            things = response['Items']
            temp_sum = 0.00
            data_num = 0
            for thing in things:
                payload = thing['payload']
                M = payload['M']
                sensor_id = M['sensorId']
                timestamp = M['timeStamp']
                time_stamp = int(timestamp['N'])
#                if sensor_id['N'] == sensor_num and time_stamp >= start_time and time_stamp <= end_time :
                if sensor_id['N'] == sensor_num:
                    temperature = M['temp']
                    temp_sum += float(temperature['N'])
                    data_num = data_num + 1
            if data_num == 0:
                print('No Available Data Points')
            else:
                print('The average temperature is', temp_sum / data_num)


        if self.option == 2:
            Max_time = 0
            latest_temp = 0.00
            for thing in things:
                payload = thing['payload']
                M = payload['M']
                sensor_id = M['sensorId']
                timestamp = M['timeStamp']
                time_temp = int(timestamp['N'])
                if sensor_id['N'] == sensor_num and timestamp > Max_time:
                    Max_time = timestamp;
                    temperature = M['temp']
                    latest_temp = temperature['N']
            print('Latest Temperature is', latest_temp)

class PlotCanvas(FigureCanvas):
    def __init__(self, parent=None, width=5, height=4, dpi=100, x_data=[], y_data=[]):
        fig = Figure(figsize=(width, height), dpi=dpi)
        self.axes = fig.add_subplot(111)

        FigureCanvas.__init__(self, fig)
        self.setParent(parent)

        FigureCanvas.setSizePolicy(self,
                                   QSizePolicy.Expanding,
                                   QSizePolicy.Expanding)
        FigureCanvas.updateGeometry(self)

        self.x_data = x_data
        self.y_data = y_data

        self.plot()

    def plot(self):
        if len(self.x_data) != 0:
            ax = self.figure.add_subplot(111)
            ax.clear()
            ax.plot(self.x_data, self.y_data)
            ax.set_title('Temperature Plot')
            self.draw()

    def setXY(self, input_X, input_Y):
        self.x_data = input_X
        self.y_data = input_Y


if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = App()
    sys.exit(app.exec_())

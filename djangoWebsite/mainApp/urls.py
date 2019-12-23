from django.conf.urls import url
from mainApp import views
import atexit

app_name = 'mainApp'

views.runAtStartup()
atexit.register(views.runAtExit)

urlpatterns = [
	url(r'^setLed$', views.setLed, name='setLed'),
	url(r'^$', views.home, name='home'),
]
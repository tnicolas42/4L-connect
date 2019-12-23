from django.conf.urls import url
from mainApp import views

app_name = 'mainApp'

views.runAtStartup()

urlpatterns = [
	url(r'^setLed$', views.setLed, name='setLed'),
	url(r'^$', views.home, name='home'),
]
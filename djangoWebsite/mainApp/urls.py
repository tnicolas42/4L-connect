from django.conf.urls import url
from mainApp import views

app_name = 'mainApp'

urlpatterns = [
	url(r'^$', views.home, name='home'),
]
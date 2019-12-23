from django.conf.urls import url
from api import views
import atexit

app_name = 'api'

views.runAtStartup()
atexit.register(views.runAtExit)

urlpatterns = [
	url(r'^setLed$', views.setLed, name='setLed'),
]
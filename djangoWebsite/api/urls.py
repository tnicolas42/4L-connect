from django.conf.urls import url
from django.http import StreamingHttpResponse
from api import views
import atexit

app_name = 'api'

views.runAtStartup()
atexit.register(views.runAtExit)

urlpatterns = [
	url(r'^getInfo$', views.getInfo, name='getInfo'),
	url(r'^setLed$', views.setLed, name='setLed'),
    url(r'^cameraStream$', lambda r: StreamingHttpResponse(views.cameraStream(),
                    content_type='multipart/x-mixed-replace; boundary=frame'),
					name='cameraStream'),
]
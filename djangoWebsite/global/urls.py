from django.conf.urls import url
from django.contrib.auth import views as auth_views

app_name = 'global'

urlpatterns = [
	url(r'^login/$', auth_views.LoginView.as_view(template_name="global/login.html"), name='login'),
	url(r'^logout/$', auth_views.LogoutView.as_view(template_name="global/login.html"), name='logout'),
	url(r'^$', auth_views.LoginView.as_view(template_name="global/login.html")),
]

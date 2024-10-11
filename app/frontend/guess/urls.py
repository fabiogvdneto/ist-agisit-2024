from django.urls import path
from . import views

urlpatterns = [
    path('', views.begin, name='begin'),
    path('guess/', views.guess_number, name='guess_number'),
    path('guess/', views.error_page, name='error_page'),
]

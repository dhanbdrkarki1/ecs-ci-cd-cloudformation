from django.urls import path
from blog.views import *
from blog.feeds import LatestPostsFeed

app_name = 'blog'

urlpatterns = [
    path('', home, name='home'),
    path('about/', about, name='about'),
    path('contact/', contact, name='contact'),
    path('all-posts/',post_list, name='post_list'),
    path('tag/<slug:tag_slug>/', post_list, name='post_list_by_tag'),
    path('<int:year>/<int:month>/<int:day>/<slug:post>/', post_detail, name='post_detail'),
    path('<int:post_id>/share/', post_share, name='post_share'),
    path('<int:post_id>/comment/', post_comment, name='post_comment'),
    path('feed/',LatestPostsFeed(), name='post_feed'),
    path('search/',post_search, name='post_search'),
    path('contact/send-message/',send_message, name='sent_message'),
]
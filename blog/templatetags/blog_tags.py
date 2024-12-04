from django import template
from blog.models import Post
from django.db.models import Count

register = template.Library()
# simple tag -> processes the given data and returns a string

@register.simple_tag
def total_posts():
    return Post.published.count()


# inclusion_tag -> ... and returns a rendered template
@register.inclusion_tag('blog/latest_posts.html')
def show_latest_posts(count=2):
    latest_posts = Post.published.order_by('-publish')[:count]
    return {'latest_posts': latest_posts}


@register.simple_tag
def get_most_commented_posts(count=3):
    return Post.published.annotate(total_comments=Count('comments')).order_by('-total_comments')[:count]


# markdown
# Markdown is a plain text formatting syntax  and it’s intended to be converted
# into HTML.
# config -> pip install markdown
# mark_safe function provided by Django to mark the result as safe HTML to be rendered
# in the template.

from django.utils.safestring import mark_safe
import markdown

@register.filter(name='htmlformat')
def markdown_format(text):
    return mark_safe(markdown.markdown(text))
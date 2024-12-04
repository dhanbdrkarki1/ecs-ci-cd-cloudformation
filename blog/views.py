from django.shortcuts import render, redirect,get_object_or_404
from django.http import Http404
from blog.models import *
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger

from django.views.generic import ListView
from blog.forms import *
from django.core.mail import send_mail

from django.views.decorators.http import require_POST
from taggit.models import Tag

from django.contrib.postgres.search import SearchVector, SearchQuery, SearchRank

def home(request):
    recent_posts =  Post.published.order_by('-publish')[:3]
    all_tags = Tag.objects.all()
    return render(request, 'blog/home.html', {'recent_posts':recent_posts,'all_tags':all_tags})

def about(request):
    return render(request, 'blog/about.html')

def contact(request):
    return render(request, 'blog/contact.html')

def post_list(request, tag_slug=None):
    post_list = Post.published.all()
    all_tags = Tag.objects.all()
    tag = None
    if tag_slug:
        tag = get_object_or_404(Tag, slug=tag_slug)
        post_list = post_list.filter(tags__in=[tag])

    paginator = Paginator(post_list, 4)
    page_number = request.GET.get('page',1)
    try:
        posts = paginator.page(page_number)
    except PageNotAnInteger:
        posts = paginator.page(1)
    except EmptyPage:
        # assigning last page is out of range
        posts = paginator.page(paginator.num_pages)

    return render(request,'blog/post_list.html', {'posts':posts, 'all_tags':all_tags, 'tag':tag})


def post_detail(request,post, year, month, day):
    post = get_object_or_404(Post, slug=post,  publish__year=year,publish__month=month,publish__day=day, status=Post.Status.PUBLISHED)
    all_tags = Tag.objects.all()
    comments = post.comments.filter(active=True)
    form = CommentForm()
    # similar posts
    post_tags_ids = post.tags.values_list('id', flat=True)
    similar_posts = Post.published.filter(tags__in=post_tags_ids).exclude(id=post.id)
    similar_posts = similar_posts.annotate(same_tags=Count('tags')).order_by('-same_tags','-publish')[:4]
    return render(request, 'blog/post_detail.html', {'post':post, 'all_tags':all_tags,'comments':comments,'form':form, 'similar_posts': similar_posts})



def post_share(request, post_id):
    post = get_object_or_404(Post, id=post_id, status=Post.Status.PUBLISHED)
    sent = False
    if request.method == 'POST':
        form = EmailPostForm(request.POST)
        if form.is_valid():
            data  = form.cleaned_data
            post_url = request.build_absolute_uri(post.get_absolute_url())
            subject = f"{data['name']} recommends you to read {post.title}"
            message = f"Read {post.title} at {post_url} \n\n"
            send_mail(subject, message, 'hunterdbk5@gmail.com',[data['to']],fail_silently=False)
            sent = True

     
    else:
        form = EmailPostForm()
    return render(request, 'blog/share.html', {'post':post,'form':form,'sent':sent})

def send_message(request):
    if request.method == 'POST':
        name = request.POST.get('name')
        print("=-----",name)
        email = request.POST.get('email')
        subject = request.POST.get('subject')
        message = request.POST.get('message')
        subject = f"{subject}"
        message = f"{message} \n\n"
        send_mail(subject, message, email,['hunterdbk5@gmail.com',],fail_silently=False)
        print("Email sent successfully -----------")
    return redirect(reverse('blog:contact'))



@require_POST
def post_comment(request, post_id):
    post = get_object_or_404(Post,id=post_id, status=Post.Status.PUBLISHED)
    comment = None
    form = CommentForm(data=request.POST)
    if form.is_valid():
        comment = form.save(commit=False)
        comment.post = post
        comment.save()
        return redirect(post.get_absolute_url())
    return render(request, 'blog/comment.html',{'post':post, 'form':form, 'comment':comment})


def post_search(request):
    form = SearchForm()
    query = None
    results = []

    if 'query' in request.GET:
        form = SearchForm(request.GET)
        if form.is_valid():
            query = form.cleaned_data['query']
            search_vector = SearchVector('title', weight='A') + SearchVector('body',weight='B')
            search_query = SearchQuery(query)
            results = Post.published.annotate(
                search=search_vector, rank=SearchRank(search_vector, search_query)
            ).filter(rank__gte=0.3).order_by('-rank')
    return render(request, 'blog/search.html', {'form':form,'query':query, 'results':results})
            
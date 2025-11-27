import { Body, Controller, Get, HttpCode, NotFoundException, Param, Post, Put, Req } from '@nestjs/common';
import { PostDto } from './postDto';

let posts: PostDto[] = [
  new PostDto({
    id: '1',
    title: 'Post 1',
    content: 'Content 1',
    createdAt: new Date(),
    updatedAt: new Date(),
  }),
  new PostDto({
    id: '2',
    title: 'Post 2',
    content: 'Content 2',
    createdAt: new Date(),
    updatedAt: new Date(),
  }),
];

@Controller('posts')
export class PostsController {
  @Get()
  @HttpCode(200)
  findAll(@Req() request: Request): PostDto[] {
    return posts;
  }

  @Get(':id')
  findOne(@Param('id') id: string): PostDto {
    const post = posts.find((post) => post.id === id);
    if (!post) {
      throw new NotFoundException('Post not found');
    }
    return post;
  }

  @Post()
  @HttpCode(201)
  create(@Body() postDto: PostDto): PostDto {
    const newPost = new PostDto({
      id: crypto.randomUUID().toString(),
      title: postDto.title + ' ' + posts.length + 1,
      content: postDto.content + ' ' + posts.length + 1,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    posts.push(newPost);
    return newPost;
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() postDto: PostDto): PostDto {
    const index = posts.findIndex((post) => post.id === id);
    if (index === -1) {
      throw new NotFoundException('Post not found');
    }
    posts[index] = new PostDto({
      id: id,
      title: postDto.title,
      content: postDto.content,
      createdAt: postDto.createdAt,
      updatedAt: new Date(),
    });
    return posts[index];
  }
}

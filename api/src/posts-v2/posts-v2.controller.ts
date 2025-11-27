import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
} from '@nestjs/common';
import { PostsV2Service } from './posts-v2.service';
import { Post as PostEntity } from './post.entity';

@Controller('v2/posts')
export class PostsV2Controller {
  constructor(private readonly postsService: PostsV2Service) {}

  @Get()
  findAll(): Promise<PostEntity[]> {
    return this.postsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<PostEntity> {
    return this.postsService.findOne(id);
  }

  @Post()
  create(@Body() postData: Partial<PostEntity>): Promise<PostEntity> {
    return this.postsService.create(postData);
  }

  @Put(':id')
  update(
    @Param('id') id: string,
    @Body() postData: Partial<PostEntity>,
  ): Promise<PostEntity> {
    return this.postsService.update(id, postData);
  }

  @Delete(':id')
  remove(@Param('id') id: string): Promise<void> {
    return this.postsService.remove(id);
  }
}

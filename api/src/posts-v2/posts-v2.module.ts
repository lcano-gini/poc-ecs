import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PostsV2Service } from './posts-v2.service';
import { PostsV2Controller } from './posts-v2.controller';
import { Post } from './post.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Post])],
  providers: [PostsV2Service],
  controllers: [PostsV2Controller],
})
export class PostsV2Module {}

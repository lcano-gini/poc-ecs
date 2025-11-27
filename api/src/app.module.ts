import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PostsController } from './post-v1/posts.controller';
import { PostsV2Module } from './posts-v2/posts-v2.module';
import { Post } from './posts-v2/post.entity';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432', 10),
      username: process.env.DB_USERNAME || 'postgres',
      password: process.env.DB_PASSWORD || 'pocdb!',
      database: process.env.DB_NAME || 'pocdb',
      entities: [Post],
      synchronize: false, // Set to false in production
    }),
    PostsV2Module,
  ],
  controllers: [AppController, PostsController],
  providers: [AppService],
})
export class AppModule {}

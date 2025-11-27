import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PostsController } from './controllers/posts.controller';

@Module({
  imports: [],
  controllers: [AppController, PostsController],
  providers: [AppService],
})
export class AppModule {}

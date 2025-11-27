export class PostDto {
  id: string;
  title: string;
  content: string;
  createdAt: Date;
  updatedAt: Date;

  constructor(data: Partial<PostDto>) {
    Object.assign(this, data);
  }
}

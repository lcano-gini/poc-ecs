import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitialSchema1732826000000 implements MigrationInterface {
  name = 'InitialSchema1732826000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`);
    await queryRunner.query(
      `CREATE TABLE "post" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(), 
        "title" character varying NOT NULL, 
        "content" character varying NOT NULL, 
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(), 
        "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), 
        CONSTRAINT "PK_post_id" PRIMARY KEY ("id")
      )`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "post"`);
  }
}

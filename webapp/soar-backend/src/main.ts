import { Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const configService: ConfigService = app.get(ConfigService);

  app.enableCors();

  const PORT = configService.get('port');

  await app.listen(PORT, () => {
    Logger.log(`App is ready on port ${PORT} !`);
  });
}
bootstrap();

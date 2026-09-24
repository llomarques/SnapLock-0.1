import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:dotenv/dotenv.dart';

final env = DotEnv()..load();
final cloudinary = Cloudinary.fromStringUrl(env['CLOUDINARY_URL'] ?? '');

const Map<String, String> jsonHeaders = {
	'content-type': 'application/json; charset=utf-8',
};

import fs from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");
const source = fs.readFileSync(path.join(root, "frontend/src/content/blogs.ts"), "utf8");
const imageKeys = ["insightConsultation", "insightFemaleFertility", "insightSpermHealth", "ivfCare", "eggFreezing", "consultation", "icsi", "geneticTesting"];
const imageSource = fs.readFileSync(path.join(root, "frontend/src/lib/images.ts"), "utf8");
const images = Object.fromEntries(imageKeys.map((key) => {
  const match = imageSource.match(new RegExp(`${key}:\\s*\\{\\s*src:\\s*([\\"'][^\\"']+[\\"'])\\s*,\\s*alt:\\s*([\\"'][^\\"']+[\\"'])`));
  if (!match) throw new Error(`Missing image ${key}`);
  return [key, { src: JSON.parse(match[1].replaceAll("'", '"')), alt: JSON.parse(match[2].replaceAll("'", '"')) }];
}));

let code = source
  .replace(/^import .*?;\r?\n\r?\n/, "")
  .replace(/export type [\s\S]*?;\r?\n\r?\n/g, "")
  .replace(/(:\s*[A-Za-z_$][\w$]*(?:<[^>]+>)?(?:\[\])?)(\s*=)/g, "$2")
  .replaceAll("function getBlog(slug: string)", "function getBlog(slug)")
  .replaceAll("function getNextBlog(slug: string)", "function getNextBlog(slug)")
  .replaceAll("function getRelatedBlogs(slug: string, limit = 3)", "function getRelatedBlogs(slug, limit = 3)")
  .replaceAll("export const blogs", "const blogs")
  .replaceAll("export function", "function");
const blogs = Function("images", `${code}\nreturn blogs;`)(images);
const arabic = {
  "fertility-test-guide": ["فحوصات الخصوبة: دليل خطوة بخطوة للأزواج", "دليل واضح لفحوصات الخصوبة، من الاستشارة الأولى حتى فهم النتائج والخطوات التالية."],
  "first-ivf-consultation": ["ماذا تتوقع خلال استشارتك الأولى لأطفال الأنابيب؟", "تعرّف على الخطوات الأولى في رحلة أطفال الأنابيب وما سيناقشه معك أخصائيو الخصوبة."],
  "age-and-female-fertility": ["كيف يؤثر العمر في خصوبة المرأة؟", "دليل مبسط يشرح تغير الخصوبة مع الوقت والخيارات المتاحة لك."],
  "sperm-health": ["فهم صحة الحيوانات المنوية والعوامل المؤثرة فيها", "العوامل التي تؤثر في جودة الحيوانات المنوية وكيف يقيّم أطباؤنا عقم الرجال ويعالجونه."],
  "preparing-for-ivf": ["كيف تستعد لدورة أطفال الأنابيب؟", "خطوات عملية للاستعداد للعلاج، من نمط الحياة ومواعيد الأدوية إلى الاستعداد النفسي."],
  "egg-freezing-guide": ["تجميد البويضات: ما تحتاج إلى معرفته", "شرح واضح لتجميد البويضات ومتى يمكن أن يكون خياراً مناسباً للحفاظ على الخصوبة."],
  "male-fertility-testing": ["فحوصات خصوبة الرجال: ما الذي تتضمنه؟", "فهم الفحوصات الأساسية والمتقدمة التي تساعد على تقييم خصوبة الرجل."],
  "icsi-explained": ["الحقن المجهري: شرح مبسط", "كيف يتم الحقن المجهري، ومتى قد يوصي به اختصاصي الخصوبة، وما الذي يمكن توقعه."],
  "genetic-testing-embryos": ["الفحص الجيني للأجنة: دليل عملي", "معلومات أساسية عن فحص الأجنة جينياً، فوائده وحدوده والأسئلة التي ينبغي مناقشتها مع الطبيب."],
};
const arabicSections = (blog) => [
  { title: "لماذا يهم هذا الموضوع؟", tone: "ink", paragraphs: ["تختلف رحلة الخصوبة من شخص إلى آخر. يساعدك الفهم الجيد للمعلومات الطبية على اتخاذ قرارات مناسبة بالتعاون مع فريقك المتخصص.", "ابدأ دائماً باستشارة اختصاصي يراجع تاريخك الصحي ويشرح الخيارات المتاحة بوضوح."], list: [{ text: "مراجعة التاريخ الصحي والإنجابي" }, { text: "فهم الفحوصات والنتائج" }, { text: "اختيار الخطوات التالية المناسبة" }] },
  { title: "ما الذي يحدث خلال التقييم؟", tone: "brand", paragraphs: ["يجمع فريق الخصوبة المعلومات اللازمة عن كلا الشريكين، ثم يحدد الفحوصات أو الإجراءات التي تناسب الحالة. قد تشمل الخطة تحاليل الدم، التصوير، تحليل السائل المنوي أو فحوصات إضافية."], list: [{ text: "مناقشة الأعراض والتاريخ الطبي" }, { text: "شرح الفحوصات المطلوبة" }, { text: "مراجعة النتائج مع الطبيب" }] },
  { title: "ماذا يحدث بعد ذلك؟", tone: "ink", paragraphs: ["بعد اكتمال التقييم، يشرح لك اختصاصي الخصوبة النتائج ويقترح خطة شخصية. لا توجد نتيجة واحدة تناسب الجميع، لذلك تُتخذ القرارات بعد مناقشة الفوائد والحدود والبدائل."], list: [{ text: "اطرح أسئلتك على فريقك الطبي" }, { text: "اطلب شرح أي نتيجة غير واضحة" }, { text: "اتبع الخطة المتفق عليها" }] },
  { title: "نصيحة مهمة", tone: "brand", paragraphs: ["تواصل مع عيادتك إذا احتجت إلى دعم أو ظهرت لديك أسئلة جديدة. المعلومات العامة لا تغني عن الاستشارة الطبية الشخصية."] },
];
const imageIds = { "fertility-test-guide": 1701, "first-ivf-consultation": 1701, "age-and-female-fertility": 1702, "sperm-health": 1703, "preparing-for-ivf": 1704, "egg-freezing-guide": 1705, "male-fertility-testing": 1706, "icsi-explained": 1707, "genetic-testing-embryos": 1708 };
const entries = blogs.flatMap((blog) => [
  { slug: blog.slug, locale: "en", title: blog.title, status: "publish", data: { ...blog, image: { ...blog.image, imageId: imageIds[blog.slug] } } },
  { slug: blog.slug, locale: "ar", title: arabic[blog.slug][0], status: "publish", data: { ...blog, image: { ...blog.image, imageId: imageIds[blog.slug] }, title: arabic[blog.slug][0], excerpt: arabic[blog.slug][1], category: "إرشادات", author: "فريق بورن هول", sections: arabicSections(blog), relatedHeading: { before: "اكتشف المزيد من ", accent: "مقالات الخصوبة", after: "" } } },
]);
const output = process.argv[2] ? path.resolve(process.argv[2]) : path.join(root, "tools/blog-content.seed.json");
fs.writeFileSync(output, `${JSON.stringify({ blogs: entries }, null, 2)}\n`);
console.log(`Generated ${entries.length} managed blog records at ${output}`);

<?php

if ( PHP_SAPI !== 'cli' ) exit( 1 );
require dirname( __DIR__ ) . '/backend/wp-load.php';

$names = array(
    'sami-elhadi' => 'سامي الهادي', 'ahmed-mohammed-nasr' => 'أحمد محمد نصر', 'sanaa-maalouf' => 'سناء معلوف', 'madiha-mustafa' => 'مديحة مصطفى', 'ruba-najjar' => 'ربى نجار', 'dalya-hassan' => 'داليا حسن', 'eman-ahmad' => 'إيمان أحمد', 'linda-bouhafs' => 'ليندا بوحفص', 'geraldine-emerson' => 'جيرالدين إيمرسون', 'dr-gautam-allahbadia' => 'د. غوتام اللهباديا', 'dr-ali-thwaini' => 'د. علي الثويني', 'dr-heba-hashem' => 'د. هبة هاشم', 'dr-munira-furniturewala' => 'د. منيرة فِرنتشر والا', 'dr-majeed-aloum' => 'د. ماجد العوم', 'dr-limia-ibrahim' => 'د. ليميا إبراهيم', 'dr-larissa-schindler' => 'د. لاريسا شيندلر', 'dr-shazia-magray' => 'د. شازيا مغراي', 'dr-sajida-detho' => 'د. ساجدة ديتهو', 'dr-ghada-hussein' => 'د. غادة حسين',
);
$roles = array(
    'Medical Laboratory Technologist' => 'أخصائي تقنيات مختبرية طبية', 'Senior Clinical Embryologist' => 'أخصائي أول في علم الأجنة السريري', 'Laboratory Manager' => 'مدير المختبر', 'Laboratory Operations Director' => 'مدير عمليات المختبر', 'Group Laboratory Director' => 'مدير مختبر المجموعة', 'Consultant' => 'استشاري', 'Consultant Urologist' => 'استشاري جراحة المسالك البولية', 'Specialist Obstetrics and Gynaecology' => 'أخصائي النساء والتوليد', 'Specialist Reproductive Medicine' => 'أخصائي طب الإنجاب', 'Medical Director' => 'المدير الطبي',
);
$clinics = array( 'Dubai' => 'دبي', 'Abu Dhabi' => 'أبوظبي', 'Al Ain' => 'العين' );
$nationalities = array( 'Indian' => 'هندي', 'British' => 'بريطاني', 'Egyptian/American' => 'مصري/أمريكي', 'Irish' => 'أيرلندي', 'Swedish, Iraqi' => 'سويدي، عراقي', 'French-Brazilian' => 'فرنسي-برازيلي' );
$languages = array( 'English' => 'الإنجليزية', 'Arabic' => 'العربية', 'Urdu' => 'الأردية', 'Hindi' => 'الهندية', 'Spanish' => 'الإسبانية', 'Gujarati' => 'الغوجاراتية', 'Turkish' => 'التركية', 'French' => 'الفرنسية', 'Italian' => 'الإيطالية', 'Portuguese' => 'البرتغالية', 'Swedish fluently' => 'السويدية بطلاقة', 'Sindhi' => 'السندية', 'Punjabi' => 'البنجابية' );

function ar_doctor_text( $value ) {
    global $roles, $clinics, $nationalities, $languages;
    if ( isset( $roles[ $value ] ) ) return $roles[ $value ];
    if ( isset( $clinics[ $value ] ) ) return $clinics[ $value ];
    if ( isset( $nationalities[ $value ] ) ) return $nationalities[ $value ];
    $parts = preg_split( '/\s*,\s*/', (string) $value );
    if ( count( $parts ) > 1 && count( array_filter( $parts, static fn( $part ) => isset( $languages[ $part ] ) ) ) === count( $parts ) ) return implode( '، ', array_map( static fn( $part ) => $languages[ $part ], $parts ) );
    return (string) $value;
}

$seed_path = dirname( __DIR__ ) . '/tools/arabic-content.seed.json';
$seed = json_decode( (string) file_get_contents( $seed_path ), true );
$seed['doctors'] = array();
$posts = get_posts( array( 'post_type' => 'bh_doctor', 'post_status' => 'publish', 'numberposts' => -1 ) );
foreach ( $posts as $post ) {
    $data = json_decode( (string) get_post_meta( $post->ID, BROUNHALL_ENTITY_DATA_META, true ), true );
    $data = is_array( $data ) ? $data : array();
    $role = ar_doctor_text( $data['role'] ?? '' );
    $type = ( $data['type'] ?? 'doctor' ) === 'embryologist' ? 'أخصائي أجنة' : 'طبيب خصوبة';
    $arabic = array(
        'name' => $names[ $post->post_name ] ?? $post->post_title,
        'role' => $role ?: $type,
        'headline' => $role ?: $type,
        'specialty' => $type === 'أخصائي أجنة' ? 'علم الأجنة السريري' : 'طب الإنجاب والخصوبة',
        'clinic' => ar_doctor_text( $data['clinic'] ?? '' ),
        'nationality' => ar_doctor_text( $data['nationality'] ?? '' ),
        'languages' => ar_doctor_text( $data['languages'] ?? '' ),
        'areasOfInterest' => $type === 'أخصائي أجنة' ? 'تقنيات مختبرات الأجنة والإنجاب المساعد.' : 'تقييم الخصوبة وعلاج العقم وتقنيات الإنجاب المساعد.',
        'education' => 'المؤهلات الأكاديمية والخبرات المهنية موضحة ضمن الملف الطبي للطبيب.',
        'bio' => $type === 'أخصائي أجنة' ? 'يقدم رعاية مخبرية متخصصة في علم الأجنة وتقنيات الإنجاب المساعد ضمن فريق بورن هول.' : 'يقدم تقييماً شاملاً للخصوبة وخطط علاج مخصصة للمرضى والأزواج ضمن فريق بورن هول.',
    );
    $seed['doctors'][] = array( 'slug' => $post->post_name, 'arabic' => $arabic );
}
file_put_contents( $seed_path, json_encode( $seed, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT ) . PHP_EOL );
echo 'Generated Arabic doctor data for ' . count( $seed['doctors'] ) . " records.\n";

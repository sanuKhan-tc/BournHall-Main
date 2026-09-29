<?php

declare(strict_types=1);

$seedFile = $argv[1] ?? '';
if ($seedFile === '' || !is_readable($seedFile)) {
    fwrite(STDERR, "Usage: php tools/seed-blogs.php <seed.json> [--execute] [--replace]\n");
    exit(1);
}

require dirname(__DIR__) . '/backend/wp-load.php';
$data = json_decode((string) file_get_contents($seedFile), true);
if (!is_array($data) || !is_array($data['blogs'] ?? null)) {
    fwrite(STDERR, "Seed JSON must contain a blogs array.\n");
    exit(1);
}

$execute = in_array('--execute', $argv, true);
$replace = in_array('--replace', $argv, true);
$counts = ['blogs' => []];
$record = static function (string $result) use (&$counts): void {
    $counts['blogs'][$result] = ($counts['blogs'][$result] ?? 0) + 1;
};
if ($replace) $counts['blogs']['cleared'] = brounhall_locale_clear_blogs($execute);
foreach ($data['blogs'] as $item) $record(brounhall_locale_migrate_blog($item, $execute));
echo ($execute ? 'Blog migration completed. ' : 'Dry run only. Nothing was written. ') . wp_json_encode($counts) . PHP_EOL;

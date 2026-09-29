<?php

declare(strict_types=1);

$seedFile = $argv[1] ?? '';
if ($seedFile === '' || !is_readable($seedFile)) {
    fwrite(STDERR, "Usage: php tools/seed-arabic-content.php <seed.json> [--execute]\n");
    exit(1);
}

require dirname(__DIR__) . '/backend/wp-load.php';
$data = json_decode((string) file_get_contents($seedFile), true);
if (!is_array($data)) {
    fwrite(STDERR, "Invalid seed JSON.\n");
    exit(1);
}

$execute = in_array('--execute', $argv, true);
$counts = ['pages' => [], 'treatments' => [], 'doctors' => []];
$record = static function (string $type, string $result) use (&$counts): void {
    $counts[$type][$result] = ($counts[$type][$result] ?? 0) + 1;
};

foreach ((array) ($data['pages'] ?? []) as $item) $record('pages', brounhall_locale_migrate_page($item, $execute));
foreach ((array) ($data['treatments'] ?? []) as $item) $record('treatments', brounhall_locale_migrate_treatment($item, $execute));
foreach ((array) ($data['doctors'] ?? []) as $item) $record('doctors', brounhall_locale_migrate_doctor($item, $execute));

echo ($execute ? 'Arabic migration completed. ' : 'Dry run only. Nothing was written. ') . wp_json_encode($counts) . PHP_EOL;

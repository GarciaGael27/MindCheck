-- =============================================================================
-- MindCheck — Seed: MBI-SS (Maslach Burnout Inventory - Student Survey)
-- =============================================================================
-- Spanish-validated version. All items are LOCKED to preserve psychometric
-- validity. Edits require explicit unlock + reason via admin panel.
-- =============================================================================

-- Instrument definition -------------------------------------------------------
insert into public.instruments
  (code, name, description, language, total_items, scale_min, scale_max, validated_source, active)
values (
  'mbi_ss',
  'Maslach Burnout Inventory — Student Survey (MBI-SS)',
  'Inventario de burnout académico de Maslach para estudiantes universitarios. Mide tres dimensiones: agotamiento emocional, cinismo y eficacia académica.',
  'es',
  15,
  0,
  6,
  'Schaufeli, W. B., Martínez, I. M., Pinto, A. M., Salanova, M., & Bakker, A. B. (2002). Burnout and engagement in university students. Journal of Cross-Cultural Psychology, 33(5), 464-481.',
  true
)
on conflict (code) do update set
  name = excluded.name,
  description = excluded.description,
  total_items = excluded.total_items,
  validated_source = excluded.validated_source,
  active = excluded.active;

-- Items (locked = true) -------------------------------------------------------
insert into public.instrument_items
  (instrument, item_number, text, dimension, reverse_scored, locked, version, source_citation)
values
  ('mbi_ss',  1, 'Me siento emocionalmente agotado por mis estudios',                                     'exhaustion', false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss',  2, 'Me siento cansado al final de una jornada de estudio',                                  'exhaustion', false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss',  3, 'Me siento fatigado cuando me levanto y tengo que enfrentar otro día de estudio',        'exhaustion', false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss',  4, 'Estudiar o asistir a clase es realmente una tensión para mí',                          'exhaustion', false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss',  5, 'Me siento acabado por mis estudios',                                                    'exhaustion', false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss',  6, 'He perdido interés en mis estudios',                                                    'cynicism',   false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss',  7, 'He perdido entusiasmo por mis estudios',                                                'cynicism',   false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss',  8, 'Me he vuelto más cínico sobre la utilidad potencial de mis estudios',                   'cynicism',   false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss',  9, 'Dudo de la importancia de mis estudios',                                                'cynicism',   false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss', 10, 'Puedo resolver de manera eficaz los problemas relacionados con mis estudios',           'efficacy',   false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss', 11, 'Creo que contribuyo efectivamente durante mis clases',                                  'efficacy',   false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss', 12, 'En mi opinión soy un buen estudiante',                                                  'efficacy',   false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss', 13, 'Me estimula conseguir objetivos en mis estudios',                                       'efficacy',   false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss', 14, 'He aprendido muchas cosas interesantes durante mis estudios',                           'efficacy',   false, true, 1, 'Schaufeli et al., 2002'),
  ('mbi_ss', 15, 'Durante las clases me siento seguro de que soy eficaz en la finalización de las cosas', 'efficacy',   false, true, 1, 'Schaufeli et al., 2002')
on conflict (instrument, item_number) do update set
  text = excluded.text,
  dimension = excluded.dimension,
  locked = excluded.locked,
  source_citation = excluded.source_citation;

-- Cutoffs (default population = Schaufeli et al., 2002) ----------------------
insert into public.instrument_cutoffs
  (instrument, dimension, low_threshold, high_threshold, population, active, notes)
values
  ('mbi_ss', 'exhaustion', 2.00, 3.20, 'default', true, 'Cutoffs from Schaufeli et al., 2002. Higher = more burnout.'),
  ('mbi_ss', 'cynicism',   1.00, 2.20, 'default', true, 'Cutoffs from Schaufeli et al., 2002. Higher = more burnout.'),
  ('mbi_ss', 'efficacy',   2.99, 4.01, 'default', true, 'Reverse-scored: lower efficacy = more burnout.')
on conflict (instrument, dimension, population) do update set
  low_threshold = excluded.low_threshold,
  high_threshold = excluded.high_threshold,
  notes = excluded.notes,
  active = excluded.active;

import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

const DEMO_USER = {
  id: 'd0000000-0000-4000-8000-000000000001',
  fullName: 'Usuario Demo',
  email: 'demo@bolivaraprende.co',
  password: 'Demo12345',
};

const offers = [
  {
    id: 'a0000000-0000-4000-8000-000000000001',
    title: 'Operario de producción en planta de alimentos',
    description:
      'Se requiere operario para la línea de empaque de una planta de alimentos. Jornada diurna, contrato a término fijo de seis meses y capacitación inicial pagada.',
    type: 'job',
    institution: 'Agrosur del Bolívar',
    municipality: 'El Carmen de Bolívar',
    modality: 'onsite',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000002',
    title: 'Asesor comercial para la zona centro',
    description:
      'Asesor comercial con experiencia mínima de un año en crédito de libranza. Se ofrece salario base más comisiones y auxilio de transporte.',
    type: 'job',
    institution: 'Banco Cooperativo de Bolívar',
    municipality: 'Magangué',
    modality: 'onsite',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000003',
    title: 'Desarrollador backend junior',
    description:
      'Desarrollador junior con conocimientos en Node.js y bases de datos relacionales para construir servicios internos. Modalidad híbrida con dos días en oficina.',
    type: 'job',
    institution: 'Tecnología Caribe S.A.S.',
    municipality: 'Cartagena',
    modality: 'hybrid',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000004',
    title: 'Auxiliar de servicios generales',
    description:
      'Apoyo en el mantenimiento y aseo de las instalaciones de la alcaldía. Jornada de lunes a viernes con contrato de prestación de servicios.',
    type: 'job',
    institution: 'Alcaldía de Arjona',
    municipality: 'Arjona',
    modality: 'onsite',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000005',
    title: 'Conductor de distribución urbana',
    description:
      'Conductor con licencia C2 vigente para rutas de distribución en Cartagena. Se exige experiencia de dos años y disponibilidad de horario.',
    type: 'job',
    institution: 'Logística Portuaria del Caribe',
    municipality: 'Cartagena',
    modality: 'onsite',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000006',
    title: 'Técnico de mantenimiento industrial',
    description:
      'Técnico en mantenimiento preventivo de equipos de refrigeración industrial. Se ofrece estabilidad, capacitación y transporte desde Cartagena.',
    type: 'job',
    institution: 'Naviera del Caribe S.A.S.',
    municipality: 'Turbaco',
    modality: 'onsite',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000007',
    title: 'Recepcionista bilingüe para hotel',
    description:
      'Recepcionista con inglés intermedio para la atención de huéspedes nacionales e internacionales. Turnos rotativos con dos días de descanso.',
    type: 'job',
    institution: 'Hotel Boutique Getsemaní',
    municipality: 'Cartagena',
    modality: 'onsite',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000008',
    title: 'Asistente administrativo',
    description:
      'Asistente para gestión documental y atención al ciudadano en la secretaría de gobierno municipal. Contrato de seis meses prorrogable.',
    type: 'job',
    institution: 'Alcaldía de Magangué',
    municipality: 'Magangué',
    modality: 'onsite',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000009',
    title: 'Analista de calidad agroindustrial',
    description:
      'Analista encargado del muestreo y control de calidad en la línea de procesamiento de yuca. Formación técnica en alimentos y manejo de registros.',
    type: 'job',
    institution: 'Agrosur del Bolívar',
    municipality: 'San Juan Nepomuceno',
    modality: 'onsite',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000010',
    title: 'Técnico en programación de software',
    description:
      'Programa de formación técnica de 24 meses en desarrollo de software, con práctica empresarial y certificación al finalizar el proceso.',
    type: 'academic',
    institution: 'SENA',
    municipality: 'Cartagena',
    modality: 'onsite',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000011',
    title: 'Beca de excelencia para pregrado',
    description:
      'Cobertura del cien por ciento de la matrícula para estudiantes de Bolívar con promedio superior a 4.2 y estrato uno o dos. Incluye apoyo de sostenimiento.',
    type: 'academic',
    institution: 'Universidad de Cartagena',
    municipality: 'Cartagena',
    modality: 'onsite',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000012',
    title: 'Curso de inglés para el trabajo',
    description:
      'Curso de inglés con énfasis en atención al cliente y turismo. Niveles A1 a B1, jornada sabatina y cupos limitados por municipio.',
    type: 'academic',
    institution: 'SENA',
    municipality: 'Turbaco',
    modality: 'hybrid',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000013',
    title: 'Especialización en logística portuaria',
    description:
      'Especialización dirigida a profesionales de ingeniería y administración interesados en operaciones portuarias y cadena de suministro.',
    type: 'academic',
    institution: 'Universidad Tecnológica de Bolívar',
    municipality: 'Cartagena',
    modality: 'hybrid',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000014',
    title: 'Maestría en educación rural',
    description:
      'Programa de maestría orientado a docentes del departamento que trabajan en contextos rurales. Financiación disponible para servidores públicos.',
    type: 'academic',
    institution: 'Universidad de Cartagena',
    municipality: 'El Carmen de Bolívar',
    modality: 'hybrid',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000015',
    title: 'Diplomado en turismo sostenible',
    description:
      'Diplomado virtual de 120 horas sobre turismo comunitario y patrimonio, con énfasis en el Canal del Dique y los Montes de María.',
    type: 'academic',
    institution: 'Fundación Universitaria Tecnológico Comfenalco',
    municipality: 'Santa Cruz de Mompox',
    modality: 'remote',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000016',
    title: 'Técnico en contabilidad y finanzas',
    description:
      'Formación técnica laboral de un año en contabilidad, nómina y legislación tributaria colombiana. Incluye kit de estudio sin costo.',
    type: 'academic',
    institution: 'SENA',
    municipality: 'Arjona',
    modality: 'onsite',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000017',
    title: 'Curso de emprendimiento digital',
    description:
      'Curso gratuito de ocho semanas para crear y gestionar un negocio en línea. Incluye acompañamiento en la construcción del plan de negocio.',
    type: 'academic',
    institution: 'Gobernación de Bolívar',
    municipality: 'San Jacinto',
    modality: 'remote',
  },
  {
    id: 'a0000000-0000-4000-8000-000000000018',
    title: 'Beca de formación docente',
    description:
      'Beca para normalistas y licenciados que quieran cursar una especialización en pedagogía. Cubre el ochenta por ciento del valor de la matrícula.',
    type: 'academic',
    institution: 'Universidad de Cartagena',
    municipality: 'María La Baja',
    modality: 'onsite',
  },
];

const buildCreatedAt = (index) => new Date(Date.now() - index * 24 * 60 * 60 * 1000);

const main = async () => {
  const passwordHash = await bcrypt.hash(DEMO_USER.password, 12);

  const user = await prisma.user.upsert({
    where: { email: DEMO_USER.email },
    create: {
      id: DEMO_USER.id,
      fullName: DEMO_USER.fullName,
      email: DEMO_USER.email,
      passwordHash,
    },
    update: {
      fullName: DEMO_USER.fullName,
      passwordHash,
    },
  });

  for (const [index, offer] of offers.entries()) {
    const createdAt = buildCreatedAt(index);

    await prisma.offer.upsert({
      where: { id: offer.id },
      create: { ...offer, ownerId: user.id, createdAt, updatedAt: createdAt },
      update: { ...offer, ownerId: user.id, updatedAt: createdAt },
    });
  }

  const savedOffers = [offers[0].id, offers[9].id, offers[10].id];

  for (const offerId of savedOffers) {
    await prisma.savedOffer.upsert({
      where: { userId_offerId: { userId: user.id, offerId } },
      create: { userId: user.id, offerId },
      update: {},
    });
  }
};

main()
  .catch((error) => {
    process.stderr.write(`Fallo el seed: ${error.message}\n`);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

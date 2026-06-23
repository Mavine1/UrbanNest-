const { sequelize } = require('./src/config/database');
const User = require('./src/models/User');
const bcrypt = require('bcryptjs');

async function seed() {
  try {
    await sequelize.authenticate();
    console.log('Database connected.');

    // Sync models
    await sequelize.sync({ alter: true });
    console.log('Models synced.');

    // Seed Agents
    const agents = [
      {
        fullName: 'Mavine',
        email: 'mavine@gmail.com',
        phone: '0794461389',
        password: 'Kijabe.123',
        role: 'agent',
        isVerified: true,
      },
      {
        fullName: 'Agent Smith',
        email: 'agent.smith@urbanest.com',
        phone: '0712345678',
        password: 'Agent123!',
        role: 'agent',
        isVerified: true,
      },
      {
        fullName: 'Sarah Johnson',
        email: 'sarah.johnson@urbanest.com',
        phone: '0723456789',
        password: 'Sarah2024!',
        role: 'agent',
        isVerified: true,
      },
      {
        fullName: 'John Doe',
        email: 'john.doe@urbanest.com',
        phone: '0734567890',
        password: 'John2024!',
        role: 'agent',
        isVerified: true,
      },
    ];

    for (const agentData of agents) {
      const existing = await User.findOne({ where: { email: agentData.email } });

      if (existing) {
        console.log(`Agent ${agentData.email} already exists, skipping...`);
      } else {
        const hashedPassword = await bcrypt.hash(agentData.password, 10);
        const agent = await User.create({
          ...agentData,
          password: hashedPassword,
        });
        console.log(`Created agent: ${agent.email} (ID: ${agent.id})`);
      }
    }

    // Seed a demo buyer
    const buyerData = {
      fullName: 'Demo Buyer',
      email: 'buyer@demo.com',
      phone: '0799999999',
      password: 'Demo123!',
      role: 'buyer',
      isVerified: true,
    };

    const existingBuyer = await User.findOne({ where: { email: buyerData.email } });
    if (existingBuyer) {
      console.log(`Buyer ${buyerData.email} already exists`);
    } else {
      const hashedPassword = await bcrypt.hash(buyerData.password, 10);
      const buyer = await User.create({
        ...buyerData,
        password: hashedPassword,
      });
      console.log(`Created buyer: ${buyer.email} (ID: ${buyer.id})`);
    }

    console.log('\n✅ Seed completed successfully!');
    console.log('\nAgent Logins:');
    console.log('  1. Email: mavine@gmail.com | Password: Kijabe.123 | Phone: 0794461389');
    console.log('  2. Email: agent.smith@urbanest.com | Password: Agent123! | Phone: 0712345678');
    console.log('  3. Email: sarah.johnson@urbanest.com | Password: Sarah2024! | Phone: 0723456789');
    console.log('  4. Email: john.doe@urbanest.com | Password: John2024! | Phone: 0734567890');
    console.log('\nBuyer Login (demo):');
    console.log('  Email: buyer@demo.com | Password: Demo123! | Phone: 0799999999');

    process.exit(0);
  } catch (error) {
    console.error('Seed error:', error);
    process.exit(1);
  }
}

seed();
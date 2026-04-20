import fetch from 'node-fetch';
import { ensureEnvLoaded } from '../src/lib/env.js';

ensureEnvLoaded();

const PORT = process.env.PORT || 3000;
const BASE_URL = `http://localhost:${PORT}`;

/**
 * Test the local chat API endpoint
 */
async function testLocalChat() {
  console.log('='.repeat(60));
  console.log('Testing Local Chat API');
  console.log('='.repeat(60));
  console.log(`Target: ${BASE_URL}/api/chat\n`);

  const testQuery = 'What is the role of Saturn in astrology and astronomy?';
  const requestBody = {
    userId: 'test-user',
    sessionId: 'test-session-' + Date.now(),
    message: testQuery,
    max_context_docs: 3,
  };

  console.log('Request:');
  console.log(JSON.stringify(requestBody, null, 2));
  console.log('\n' + '-'.repeat(60) + '\n');

  try {
    const response = await fetch(`${BASE_URL}/api/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestBody),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`HTTP ${response.status}: ${errorText}`);
    }

    const data = await response.json();

    console.log('Response Status:', response.status);
    console.log('\n' + '='.repeat(60));
    console.log('ANSWER:');
    console.log('='.repeat(60));
    console.log(data.answer);
    console.log('\n' + '='.repeat(60));
    console.log('SOURCES:');
    console.log('='.repeat(60));

    if (data.sources && data.sources.length > 0) {
      data.sources.forEach((source, index) => {
        console.log(`\n[${index + 1}] ${source.title}`);
        console.log(`    Score: ${source.score.toFixed(4)}`);
        console.log(`    URL: ${source.url || 'local'}`);
        console.log(`    Snippet: ${source.snippet.substring(0, 100)}...`);
      });
    } else {
      console.log('No sources returned');
    }

    console.log('\n' + '='.repeat(60));
    console.log('ANALYSIS & UI CONTEXT:');
    console.log('='.repeat(60));
    console.log(`Verdict: ${data.uiMetadata?.verdict} (Color: ${data.uiMetadata?.color})`);
    console.log(`Action:  ${data.uiMetadata?.action}`);
    console.log(`Summary: ${data.uiMetadata?.summary}`);
    console.log('-'.repeat(30));
    console.log(`Score: ${data.analysis?.decisionScore}%`);
    console.log(`Pie Chart Labels: ${data.uiMetadata?.labels?.positive} vs ${data.uiMetadata?.labels?.negative}`);
    console.log(`Positive: ${data.analysis?.positivePercentage}% | Negative: ${data.analysis?.negativePercentage}%`);
    console.log('\nPlanet Breakdown:');

    data.analysis?.planetBreakdown?.forEach(p => {
      console.log(`- ${p.planet}: ${p.status} (Str: ${p.strength}) - ${p.reason}`);
    });

    console.log('\n' + '='.repeat(60));
    console.log('TIMING INSIGHT:');
    console.log('='.repeat(60));
    if (data.timing) {
      console.log(`Exact date possible: ${Boolean(data.timing.exactDatePossible)}`);
      console.log(`Needs birth data:    ${Boolean(data.timing.requiresBirthData)}`);
      if (Array.isArray(data.timing.favorableDates) && data.timing.favorableDates.length > 0) {
        console.log('Favorable dates:');
        data.timing.favorableDates.forEach((item, index) => {
          console.log(`  [${index + 1}] ${item.date} (${item.confidence || 'medium'}) - ${item.reason || 'No reason provided'}`);
        });
      } else {
        console.log('No favorable dates returned');
      }
      if (data.timing.note) {
        console.log(`Note: ${data.timing.note}`);
      }
    } else {
      console.log('No timing insight returned');
    }

    console.log('\n' + '='.repeat(60));
    console.log('REPORT DATA:');
    console.log('='.repeat(60));
    if (data.report) {
      console.log(`Title: ${data.report.title}`);
      console.log(`File:  ${data.report.fileName}`);
      console.log(`Date:  ${data.report.generatedOn}`);
      console.log(`Summary: ${data.report.summary}`);
      if (Array.isArray(data.report.sections) && data.report.sections.length > 0) {
        console.log('Sections:');
        data.report.sections.forEach((section, index) => {
          console.log(`  [${index + 1}] ${section.heading}: ${section.content.substring(0, 120)}...`);
        });
      }
    } else {
      console.log('No report payload returned');
    }

    console.log('\n' + '='.repeat(60));
    console.log('SHOP SUGGESTIONS:');
    console.log('='.repeat(60));
    if (data.shopSuggestions && data.shopSuggestions.length > 0) {
      data.shopSuggestions.forEach((item, index) => {
        console.log(`[${index + 1}] ${item.name} (${item.price} ${item.currency})`);
        console.log(`    ${item.description}`);
        console.log(`    Link: ${item.shopUrl}`);
      });
    } else {
      console.log('No shop suggestions returned');
    }

    console.log('\n' + '='.repeat(60));
    console.log('ASTRO NUTRITION:');
    console.log('='.repeat(60));
    if (data.nutritionGuidance) {
      console.log(`Focus: ${data.nutritionGuidance.focus || 'N/A'}`);
      console.log(`Favor: ${(data.nutritionGuidance.foodsToFavor || []).join(', ') || 'N/A'}`);
      console.log(`Go Easy: ${(data.nutritionGuidance.foodsToLimit || []).join(', ') || 'N/A'}`);
      console.log(`Meal: ${data.nutritionGuidance.mealSuggestion || 'N/A'}`);
      console.log(`Timing: ${data.nutritionGuidance.timingTip || 'N/A'}`);
    } else {
      console.log('No nutrition guidance returned');
    }

    console.log('\n' + '='.repeat(60));
    console.log('Test completed successfully!');
    console.log('='.repeat(60));


  } catch (error) {
    console.error('\n' + '='.repeat(60));
    console.error('ERROR:');
    console.error('='.repeat(60));
    console.error(error.message);

    if (error.message.includes('ECONNREFUSED')) {
      console.error('\nMake sure the server is running:');
      console.error('  npm start');
    }

    process.exit(1);
  }
}

// Run test
testLocalChat();

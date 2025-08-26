const { chromium } = require('playwright');

async function analyzeDashboard() {
    console.log('🔍 Starting comprehensive dashboard analysis...\n');
    
    const browser = await chromium.launch({ headless: false, slowMo: 1000 });
    const page = await browser.newPage();
    
    const issues = [];
    const analysis = {
        panels: [],
        templateVariables: [],
        performance: {},
        accessibility: [],
        functionality: []
    };
    
    try {
        // Set viewport for consistent testing
        await page.setViewportSize({ width: 1920, height: 1080 });
        
        console.log('📊 Navigating to dashboard...');
        await page.goto('http://localhost:3000/d/nestory-full/nestory-complete-monitoring-platform', {
            waitUntil: 'networkidle',
            timeout: 30000
        });
        await page.screenshot({ path: '/tmp/1-after-navigation.png' });
        console.log('📸 Screenshot taken: 1-after-navigation.png');
        
        // Check if login is required - try multiple selectors
        const loginRequired = await page.locator('input[name="user"], input[name="username"], [data-testid="login-form"], .login-form').first().isVisible().catch(() => false);
        if (loginRequired) {
            console.log('🔐 Logging in to Grafana...');
            await page.fill('input[name="user"], input[name="username"]', 'admin');
            await page.fill('input[name="password"]', 'nestory123');
            // Try multiple button selectors
            await page.click('button[type="submit"], [data-testid="login-button"], .btn-primary').catch(async () => {
                await page.click('button:has-text("Log in")').catch(() => {
                    return page.keyboard.press('Enter');
                });
            });
            await page.waitForLoadState('networkidle', { timeout: 10000 });
            await page.screenshot({ path: '/tmp/2-after-login.png' });
            console.log('✅ Login completed');
            console.log('📸 Screenshot taken: 2-after-login.png');
        } else {
            console.log('ℹ️  No login required - already authenticated');
            await page.screenshot({ path: '/tmp/2-no-login-needed.png' });
            console.log('📸 Screenshot taken: 2-no-login-needed.png');
        }
        
        // Wait for dashboard to load - try multiple selectors
        console.log('⏳ Waiting for dashboard to load...');
        try {
            await page.waitForSelector('[data-testid="dashboard-container"]', { timeout: 10000 });
            console.log('✅ Dashboard container found');
            await page.screenshot({ path: '/tmp/3-dashboard-container.png' });
            console.log('📸 Screenshot taken: 3-dashboard-container.png');
        } catch {
            try {
                await page.waitForSelector('.react-grid-layout', { timeout: 10000 });
                console.log('✅ React grid layout found');
                await page.screenshot({ path: '/tmp/3-react-grid-layout.png' });
                console.log('📸 Screenshot taken: 3-react-grid-layout.png');
            } catch {
                try {
                    await page.waitForSelector('[data-testid*="panel"], .panel-container, .panel', { timeout: 10000 });
                    console.log('✅ Dashboard panels found');
                    await page.screenshot({ path: '/tmp/3-dashboard-panels.png' });
                    console.log('📸 Screenshot taken: 3-dashboard-panels.png');
                } catch {
                    console.log('⚠️  No dashboard elements found - taking screenshot for debugging');
                    await page.screenshot({ path: '/tmp/3-debug-no-elements.png' });
                    console.log('📸 Screenshot taken: 3-debug-no-elements.png');
                    const title = await page.title();
                    const url = page.url();
                    console.log(`📄 Page title: ${title}`);
                    console.log(`🌐 Current URL: ${url}`);
                }
            }
        }
        
        console.log('✅ Dashboard loaded successfully\n');
        
        // === PANEL ANALYSIS ===
        console.log('🔍 Analyzing panels...');
        const panels = await page.locator('[data-testid*="panel"]').all();
        console.log(`Found ${panels.length} panels to analyze\n`);
        await page.screenshot({ path: '/tmp/4-before-panel-analysis.png' });
        console.log('📸 Screenshot taken: 4-before-panel-analysis.png');
        
        // Scroll through dashboard to load all panels and take comprehensive screenshots
        console.log('📜 Scrolling through dashboard to capture all panels...');
        const scrollHeight = await page.evaluate(() => document.body.scrollHeight);
        const viewportHeight = await page.evaluate(() => window.innerHeight);
        
        let currentScroll = 0;
        let screenshotCount = 5;
        
        while (currentScroll < scrollHeight) {
            await page.evaluate((scroll) => window.scrollTo(0, scroll), currentScroll);
            await page.waitForTimeout(1000); // Wait for panels to load
            await page.screenshot({ path: `/tmp/${screenshotCount}-scroll-${Math.round(currentScroll/viewportHeight)}.png` });
            console.log(`📸 Screenshot taken: ${screenshotCount}-scroll-${Math.round(currentScroll/viewportHeight)}.png`);
            currentScroll += viewportHeight * 0.8; // 80% overlap for continuity
            screenshotCount++;
            if (screenshotCount > 10) break; // Safety limit
        }
        
        // Scroll back to top for analysis
        await page.evaluate(() => window.scrollTo(0, 0));
        await page.waitForTimeout(1000);
        console.log('📜 Scrolling complete, back to top');
        
        for (let i = 0; i < Math.min(panels.length, 30); i++) {
            const panel = panels[i];
            try {
                const panelTitle = await panel.locator('[data-testid="panel-title"]').textContent().catch(() => 
                    panel.locator('.panel-title').textContent().catch(() => `Panel ${i + 1}`)
                );
                
                console.log(`📊 Analyzing: ${panelTitle}`);
                
                const panelAnalysis = {
                    title: panelTitle,
                    hasData: false,
                    hasError: false,
                    isLoading: false,
                    sparklines: false,
                    accessibility: true
                };
                
                // Check for error states
                const hasError = await panel.locator('.panel-status-message, .alert-error, [data-testid="panel-error"]').isVisible().catch(() => false);
                if (hasError) {
                    const errorMsg = await panel.locator('.panel-status-message, .alert-error').textContent().catch(() => 'Unknown error');
                    panelAnalysis.hasError = true;
                    issues.push(`❌ ${panelTitle}: ${errorMsg}`);
                }
                
                // Check for loading states
                const isLoading = await panel.locator('.panel-loading, .loading, [data-testid="panel-loading"]').isVisible().catch(() => false);
                panelAnalysis.isLoading = isLoading;
                
                // Check for "No data" states
                const noData = await panel.locator('.panel-no-data, .no-data').textContent().catch(() => '');
                if (noData.includes('No data')) {
                    issues.push(`⚠️  ${panelTitle}: No data available`);
                }
                
                // Check for data presence (look for charts, gauges, stats)
                const hasChart = await panel.locator('.flot-base, .uplot, svg, canvas').isVisible().catch(() => false);
                const hasStats = await panel.locator('.stat-panel-value, .gauge').isVisible().catch(() => false);
                panelAnalysis.hasData = hasChart || hasStats;
                
                // Check for sparklines (mini trend indicators)
                const hasSparklines = await panel.locator('.sparkline, .mini-chart, [data-viz="sparkline"]').isVisible().catch(() => false);
                panelAnalysis.sparklines = hasSparklines;
                
                // Check panel accessibility
                const hasAriaLabel = await panel.getAttribute('aria-label').catch(() => null);
                if (!hasAriaLabel) {
                    panelAnalysis.accessibility = false;
                    issues.push(`♿ ${panelTitle}: Missing accessibility labels`);
                }
                
                analysis.panels.push(panelAnalysis);
                
            } catch (error) {
                issues.push(`🚨 Panel ${i + 1}: Failed to analyze - ${error.message}`);
            }
        }
        
        // === TEMPLATE VARIABLES ANALYSIS ===
        console.log('\n🎛️  Analyzing template variables...');
        const variables = await page.locator('[data-testid*="variable"], .template-variable').all();
        
        for (const variable of variables) {
            try {
                const varName = await variable.textContent().catch(() => 'Unknown variable');
                console.log(`🔧 Variable: ${varName}`);
                
                // Check if variable is functional
                const isClickable = await variable.isEnabled().catch(() => false);
                if (!isClickable) {
                    issues.push(`🎛️  Variable "${varName}": Not interactive`);
                }
                
                analysis.templateVariables.push({
                    name: varName,
                    functional: isClickable
                });
            } catch (error) {
                issues.push(`🎛️  Variable analysis failed: ${error.message}`);
            }
        }
        
        // === PERFORMANCE ANALYSIS ===
        console.log('\n⚡ Analyzing performance...');
        
        const performanceEntries = await page.evaluate(() => {
            return {
                loadTime: performance.timing.loadEventEnd - performance.timing.navigationStart,
                domReady: performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart,
                resourceCount: performance.getEntriesByType('resource').length
            };
        });
        
        analysis.performance = performanceEntries;
        
        if (performanceEntries.loadTime > 10000) {
            issues.push(`⚡ Performance: Slow load time (${performanceEntries.loadTime}ms > 10s)`);
        }
        
        // === ACCESSIBILITY ANALYSIS ===
        console.log('\n♿ Analyzing accessibility...');
        
        // Check for missing alt text on images
        const images = await page.locator('img').all();
        for (const img of images) {
            const alt = await img.getAttribute('alt');
            if (!alt) {
                issues.push('♿ Accessibility: Images missing alt text');
                break;
            }
        }
        
        // Check for proper heading hierarchy
        const headings = await page.locator('h1, h2, h3, h4, h5, h6').allTextContents();
        if (headings.length === 0) {
            issues.push('♿ Accessibility: No proper heading structure');
        }
        
        // === FUNCTIONALITY TESTING ===
        console.log('\n🧪 Testing key functionality...');
        
        // Test time range picker
        try {
            const timePicker = await page.locator('[data-testid="TimePicker"], .time-picker').first();
            if (await timePicker.isVisible()) {
                console.log('✅ Time picker found and visible');
            } else {
                issues.push('🧪 Functionality: Time picker not found');
            }
        } catch (error) {
            issues.push('🧪 Functionality: Time picker test failed');
        }
        
        // Test refresh functionality
        try {
            const refreshButton = await page.locator('[data-testid="refresh-picker"], .refresh-picker').first();
            if (await refreshButton.isVisible()) {
                console.log('✅ Refresh controls found');
            } else {
                issues.push('🧪 Functionality: Refresh controls not found');
            }
        } catch (error) {
            issues.push('🧪 Functionality: Refresh controls test failed');
        }
        
        // === VISUAL VALIDATION ===
        console.log('\n👁️  Performing visual validation...');
        
        // Check for layout issues
        const bodyOverflow = await page.evaluate(() => {
            return window.getComputedStyle(document.body).overflow;
        });
        
        if (bodyOverflow === 'scroll') {
            issues.push('👁️  Visual: Unexpected horizontal scroll detected');
        }
        
        // Check for broken layouts
        const zeroHeightElements = await page.locator('[style*="height: 0"]').count();
        if (zeroHeightElements > 5) {
            issues.push('👁️  Visual: Multiple zero-height elements detected (possible layout issues)');
        }
        
        // === RESPONSIVE DESIGN ===
        console.log('\n📱 Testing responsive design...');
        
        // Test mobile breakpoint
        await page.setViewportSize({ width: 768, height: 1024 });
        await page.waitForTimeout(2000);
        
        const mobileMenuVisible = await page.locator('.mobile-menu, [data-testid="mobile-menu"]').isVisible().catch(() => false);
        const panelsOverflow = await page.evaluate(() => {
            const panels = document.querySelectorAll('[data-testid*="panel"]');
            return Array.from(panels).some(panel => panel.scrollWidth > panel.clientWidth);
        });
        
        if (panelsOverflow) {
            issues.push('📱 Responsive: Panels overflow on mobile viewport');
        }
        
        // Reset to desktop viewport
        await page.setViewportSize({ width: 1920, height: 1080 });
        
    } catch (error) {
        issues.push(`🚨 Critical Error: ${error.message}`);
    } finally {
        await browser.close();
    }
    
    // === GENERATE REPORT ===
    console.log('\n' + '='.repeat(60));
    console.log('📋 DASHBOARD ANALYSIS REPORT');
    console.log('='.repeat(60));
    
    console.log(`\n📊 PANEL ANALYSIS (${analysis.panels.length} panels)`);
    const panelsWithData = analysis.panels.filter(p => p.hasData).length;
    const panelsWithErrors = analysis.panels.filter(p => p.hasError).length;
    const panelsLoading = analysis.panels.filter(p => p.isLoading).length;
    
    console.log(`   ✅ Panels with data: ${panelsWithData}/${analysis.panels.length}`);
    console.log(`   ❌ Panels with errors: ${panelsWithErrors}/${analysis.panels.length}`);
    console.log(`   ⏳ Panels loading: ${panelsLoading}/${analysis.panels.length}`);
    
    console.log(`\n🎛️  TEMPLATE VARIABLES (${analysis.templateVariables.length} found)`);
    const functionalVars = analysis.templateVariables.filter(v => v.functional).length;
    console.log(`   ✅ Functional variables: ${functionalVars}/${analysis.templateVariables.length}`);
    
    console.log(`\n⚡ PERFORMANCE METRICS`);
    console.log(`   📈 Load time: ${analysis.performance.loadTime}ms`);
    console.log(`   🏃 DOM ready: ${analysis.performance.domReady}ms`);
    console.log(`   📦 Resources loaded: ${analysis.performance.resourceCount}`);
    
    if (issues.length === 0) {
        console.log('\n🎉 ✅ NO ISSUES FOUND - Dashboard is excellent!');
    } else {
        console.log(`\n⚠️  ISSUES IDENTIFIED (${issues.length} total):`);
        console.log('─'.repeat(50));
        issues.forEach((issue, index) => {
            console.log(`${index + 1}. ${issue}`);
        });
    }
    
    console.log('\n' + '='.repeat(60));
    console.log('Analysis complete! 🏁');
    
    return { issues, analysis };
}

// Run the analysis
analyzeDashboard().catch(console.error);
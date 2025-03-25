# pip install fastapi uvicorn crewai crewai-tools pdfplumber paddleocr reportlab python-dotenv
from datetime import datetime
import requests
import asyncio
from fastapi import APIRouter, HTTPException, UploadFile, File
from bson import ObjectId
from models.reports_model import Reports
from database import db
from datetime import date, datetime
from crewai import Agent, Task, Crew, Process, LLM
import json
from crewai_tools import SerperDevTool
from dotenv import load_dotenv
from paddleocr import PaddleOCR
import os
import json
from PIL import Image
import pdfplumber
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

router = APIRouter()
# Add language translation functions

import requests

SARVAM_API_KEY = "44de06bc-2820-4709-9f01-b60acff28d0f"
SARVAM_TRANSLATION_URL = "https://api.sarvam.ai/translate"

async def translate_to_language(text: str, lang_code: str):
    try:
        # Split the text into chunks of 950 characters (leaving some buffer)
        # Split at sentence boundaries when possible
        chunks = []
        max_chunk_size = 950
        
        # Try to split at paragraph boundaries first
        paragraphs = text.split('\n\n')
        current_chunk = ""
        
        for paragraph in paragraphs:
            if len(current_chunk) + len(paragraph) + 2 <= max_chunk_size:
                if current_chunk:
                    current_chunk += '\n\n'
                current_chunk += paragraph
            else:
                # If adding this paragraph would exceed the limit
                if current_chunk:
                    chunks.append(current_chunk)
                
                # If a single paragraph is too long, split it into sentences
                if len(paragraph) > max_chunk_size:
                    sentences = paragraph.replace('. ', '.|').split('|')
                    current_chunk = ""
                    
                    for sentence in sentences:
                        if len(current_chunk) + len(sentence) + 2 <= max_chunk_size:
                            if current_chunk:
                                current_chunk += ' '
                            current_chunk += sentence
                        else:
                            if current_chunk:
                                chunks.append(current_chunk)
                            
                            # If a single sentence is too long, split it into chunks
                            if len(sentence) > max_chunk_size:
                                for i in range(0, len(sentence), max_chunk_size):
                                    chunks.append(sentence[i:i+max_chunk_size])
                            else:
                                current_chunk = sentence
                else:
                    current_chunk = paragraph
        
        # Add the last chunk if it's not empty
        if current_chunk:
            chunks.append(current_chunk)
        
        # Translate each chunk
        translated_chunks = []
        for chunk in chunks:
            payload = {
                "input": chunk,
                "source_language_code": "en-IN",
                "target_language_code": f"{lang_code}-IN",
                "mode": "formal",
                "speaker_gender": "Female",
                "enable_preprocessing": False
            }
            headers = {"api-subscription-key": SARVAM_API_KEY}
            response = requests.post(SARVAM_TRANSLATION_URL, json=payload, headers=headers)
            
            if response.status_code == 200:
                translated_chunks.append(response.json().get("translated_text", chunk))
            else:
                print(f"Translation API error: {response.text}")
                translated_chunks.append(chunk)  # Use original chunk if translation fails
        
        # Combine the translated chunks
        translated_text = '\n\n'.join(translated_chunks)
        return translated_text
        
    except Exception as e:
        print(f"Translation error: {str(e)}")
        return text  # Return original text if translation fails

    
SUPPORTED_LANGUAGES = {
    "en": "English",  # Added English as a supported language
    "hi": "Hindi",
    "bn": "Bengali",
    "gu": "Gujarati",
    "kn": "Kannada",
    "ml": "Malayalam",
    "mr": "Marathi",
    "od": "Odia",
    "pa": "Punjabi",
    "ta": "Tamil",
    "te": "Telugu"
}

# Add endpoint to get supported languages
@router.get("/languages")
async def get_supported_languages():
    return SUPPORTED_LANGUAGES

# Helper function to validate ObjectId
def is_valid_object_id(id_str: str) -> bool:
    try:
        ObjectId(id_str)
        return True
    except Exception:
        return False
def extract_and_clean_text(input_pdf):
            cleaned_lines = []
            
            # Extract text from PDF
            with pdfplumber.open(input_pdf) as pdf:
                for page in pdf.pages:
                    text = page.extract_text()
                    if text:
                    
                        lines = [" ".join(line.split()) for line in text.split("\n")]
                    
                        cleaned_lines.extend(filter(None, lines))
                        
            return cleaned_lines

async def get_all_user_reports(user_id: str):
    """Fetch all past reports for a user and format them for analysis."""
    try:
        # Find all reports for the user, sorted by date
        past_reports = await db["reports"].find(
            {"user_id": user_id}
        ).sort("date_created", -1).to_list(length=None)  # No limit to get all reports
        
        if not past_reports:
            return ""
        
        # Format past reports into a structured string
        formatted_reports = []
        for report in past_reports:
            report_date = report.get("date_created", "").strftime("%Y-%m-%d %H:%M:%S")
            formatted_report = f"""
            Report Date: {report_date}
            Title: {report.get('report_title', 'Untitled')}
            Content:
            {report.get('report_content', '')}
            {'='*50}
            """
            formatted_reports.append(formatted_report)
        
        # Join all formatted reports with clear separation
        return "\n\n".join(formatted_reports)
    except Exception as e:
        print(f"Error fetching past reports: {str(e)}")
        return ""

# Upload and analyze report
@router.post("/analyze")
async def analyze_report(
    file: UploadFile = File(...),
    user_id: str = None,
    language: str = "en"
):
    if not user_id or not is_valid_object_id(user_id):
        raise HTTPException(status_code=400, detail="Invalid user_id")
    
    if language not in SUPPORTED_LANGUAGES:
        raise HTTPException(status_code=400, detail=f"Unsupported language code: {language}")

    temp_file_path = f"temp_{file.filename}"
    try:
        # Save the uploaded file temporarily
        with open(temp_file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        # Fetch all past reports for the user
        past_reports_data = await get_all_user_reports(user_id)
        
        # Extract text from uploaded report
        current_report_text = extract_and_clean_text(temp_file_path)
        
        # Initialize crew AI components
        # (Your existing crew AI setup code here)
        load_dotenv()
        os.environ['SERPER_API_KEY'] = "6f2227a931b482b6e1b21298ecc47bb6865beb28"

        llm = LLM(
            model="gemini/gemini-1.5-flash",
            temperature=0.7,
            api_key="AIzaSyBNOQJ3D5xVYeKt7xokZlQ-zXZrKwGgspE"

        )


        serper_tool = SerperDevTool()

        data_interpreter_agent = Agent(
            role="Medical Data Interpreter",
            goal="Accurately interpret and structure medical report data{report_text}",
            backstory="""Expert in medical laboratory data interpretation with extensive 
            experience in analyzing unstructured medical reports. Specializes in identifying 
            test parameters, values, and reference ranges.""",
            tools=[serper_tool],
            verbose=True,
            llm=llm
        )

        health_analyst_agent = Agent(
            role="Health Insights Analyst",
            goal="Analyze medical data to identify health implications{report_text}",
            backstory="""Clinical pathologist with expertise in interpreting laboratory 
            results and their implications for patient health. Specializes in connecting 
            test results to potential health conditions.""",
            tools=[serper_tool],
            verbose=True,
            llm=llm
        )

        action_insight_agent = Agent(
            role="Healthcare Action Specialist",
            goal="Develop actionable recommendations based on health insights{report_text}",
            backstory="""Healthcare consultant specializing in preventive medicine and 
            lifestyle modifications. Expert in creating practical health improvement plans 
            based on laboratory findings.""",
            tools=[serper_tool],
            verbose=True,
            llm=llm
        )

        report_compiler_agent = Agent(
            role="Medical Communication Specialist{report_text} also this is the past user report and data analyse this and have another column to corelate with this and provide information accordingly{past_report}",
            goal="Create user-friendly, comprehensive health reports",
            backstory="""Health communication expert specializing in translating complex 
            medical information into simple, actionable insights. Experienced in creating 
            reports for diverse audiences including elderly and non-medical readers.""",
            tools=[serper_tool],
            verbose=True,
            llm=llm
        )

        interpretation_task = Task(
            description="""
            {report_text}1. Analyze the unstructured medical report text
            2. Identify and categorize all test parameters:
            - Test names and categories
            - Result values and units
            - Reference ranges
            - Abnormal values
            3. Structure the data into clear categories
            4. Create trend analysis if historical data available
            5. Flag critical values requiring immediate attention
            """,
            expected_output="""
            Provide structured analysis of the medical report:

            Test Categories:
            - Complete list of test categories found
            - Key parameters within each category
            
            Results Analysis:
            - Normal results with their values
            - Abnormal results with deviation details
            - Critical values requiring attention
            
            Data Quality:
            - Missing or incomplete information
            - Unclear or ambiguous results
            - Data reliability assessment
            
            Historical Comparison:
            - Trends in test results (if available)
            - Changes from previous tests
            - Long-term patterns
            
            Technical Notes:
            - Testing methodology used
            - Any limiting factors
            - Quality control indicators
            """,
            agent=data_interpreter_agent
        )

        health_analysis_task = Task(
            description="""
            {report_text} Based on the interpreted data:
            1. Analyze each result's health implications
            2. Identify potential underlying conditions
            3. Assess overall health status
            4. Evaluate organ system functions
            5. Consider lifestyle impact on results
            6. Analyze nutrition status indicators
            7. Assess hydration and metabolic status
            """,
            expected_output="""
            Provide comprehensive health analysis:

            System Analysis:
            - Kidney function assessment
            - Liver health indicators
            - Cardiovascular status
            - Metabolic health
            - Nutritional status
            
            Risk Assessment:
            - Immediate health risks
            - Long-term health concerns
            - Preventive care needs
            
            Pattern Recognition:
            - Related symptoms to watch
            - Potential underlying conditions
            - Lifestyle factor impacts
            
            Nutritional Insights:
            - Vitamin/mineral status
            - Protein status
            - Hydration indicators
            
            Metabolic Status:
            - Blood sugar regulation
            - Energy metabolism
            - Hormone balance indicators
            """,
            agent=health_analyst_agent
        )

        action_insight_task = Task(
            description="""
            {report_text} Create comprehensive action plan including:
            1. Immediate actions needed
            2. Dietary modifications
            3. Exercise recommendations
            4. Lifestyle adjustments
            5. Supplement suggestions
            6. Medical follow-up requirements
            7. Prevention strategies
            8. Monitoring requirements
            """,
            expected_output="""
            Provide detailed actionable recommendations:

            Urgent Actions:
            - Immediate steps needed
            - Emergency signs to watch
            - When to seek immediate care
            
            Dietary Plan:
            - Foods to increase
            - Foods to avoid
            - Meal timing recommendations
            - Hydration guidelines
            
            Exercise Recommendations:
            - Suitable exercise types
            - Activity intensity levels
            - Exercise precautions
            - Progress monitoring
            
            Lifestyle Modifications:
            - Sleep recommendations
            - Stress management
            - Daily routine adjustments
            - Habit modifications
            
            Supplementation:
            - Recommended supplements
            - Dosage guidelines
            - Timing considerations
            - Precautions
            
            Medical Follow-up:
            - Specialists to consult
            - Follow-up tests needed
            - Monitoring schedule
            - Documentation needs
            """,
            agent=action_insight_agent
        )

        final_report_task = Task(
            description="""
            {report_text}Create a comprehensive, user-friendly report with visualizations:
            1. Generate clear summaries
            2. Create visual representations
            3. Use simple language
            4. Include progress tracking tools
            5. Add emergency guidelines
            6. Create quick-reference guides
            7. Also this is the past user report and data analyse this and have another column to corelate with this and provide information accordingly{past_report}
            """,
            expected_output="""
            # Your Health Report 📋

            ## Quick Summary ⚡
            Brief overview of key findings and urgent items

            ## Understanding Your Results 🔬
            ### Normal Findings ✅
            - Simple explanations of normal results
            - What these mean for your health
            
            ### Areas of Attention ⚠️
            - Clear explanation of concerning results
            - Why these matter
            - What to do about them

            ## Action Steps 🎯
            ### Immediate Actions ⚡
            - Urgent steps to take
            - When to seek medical help
            
            ### Dietary Guidelines 🍎
            - Foods to eat more
            - Foods to limit
            - Meal planning tips
            
            ### Exercise & Activity 💪
            - Recommended activities
            - Activity level guidelines
            - Safety precautions
            
            ### Lifestyle Changes 🌟
            - Sleep recommendations
            - Stress management
            - Daily routine adjustments

            ## Medical Follow-up 👨‍⚕️
            - Doctors to consult
            - Future tests needed
            - Appointment timeline
            
            ## Progress Tracking 📈
            Include relevant graphs and charts
            - Result trends
            - Goal tracking
            - Improvement metrics

            ## Emergency Guidelines 🚨
            - Warning signs
            - Emergency contacts
            - What to do in crisis

            ## Resources & Support 📚
            - Educational materials
            - Support groups
            - Helpful apps/tools
            #Relation with the past data and current report 
            - Comparison with previous results
            - Changes in health status
            - Recommendations for future monitoring           

            
            ## Next Steps Checklist ✅
            - Prioritized action items
            - Timeline for actions
            - Progress tracking tools
            """,
            agent=report_compiler_agent
        )

        crew = Crew(
            agents=[
                data_interpreter_agent,
                health_analyst_agent,
                action_insight_agent,
                report_compiler_agent
            ],
            tasks=[
                interpretation_task,
                health_analysis_task,
                action_insight_task,
                final_report_task
            ],
            process=Process.sequential
        )
        crew = Crew(
            agents=[
                data_interpreter_agent,
                health_analyst_agent,
                action_insight_agent,
                report_compiler_agent
            ],
            tasks=[
                interpretation_task,
                health_analysis_task,
                action_insight_task,
                final_report_task
            ],
            process=Process.sequential
        )
                          
        
        result = crew.kickoff(
            inputs={
                "report_text": current_report_text,
                "past_report": past_reports_data
            }
        )
        
        # Get the raw analysis as a string and ensure it's properly formatted markdown
        raw_analysis = str(result.raw) if hasattr(result, 'raw') else str(result)
        
        # Format the result content properly
        result_content = {
            "raw_analysis": raw_analysis,
            "metadata": {
                "artifacts": result.artifacts if hasattr(result, 'artifacts') else [],
                "successful_requests": result.successful_requests if hasattr(result, 'successful_requests') else 0,
                "language": SUPPORTED_LANGUAGES["en"]  # Store original language name
            }
        }
        
        # Translate if needed
        if language != "en":
            translated_text = await translate_to_language(raw_analysis, language)
            # Store both original and translated text
            result_content["translated_analysis"] = translated_text
            result_content["metadata"]["language"] = SUPPORTED_LANGUAGES[language]
        
        # Create new report entry - no need to specify date_created as it's handled by default
        new_report = Reports(
            user_id=user_id,
            report_title=file.filename,
            report_content=result_content  # Store the structured content
        )
        
        # Convert the model to a dict and save
        report_dict = new_report.dict(by_alias=True)
        saved_report = await db["reports"].insert_one(report_dict)

        # Prepare response
        response_data = {
            "id": str(saved_report.inserted_id),
            "user_id": user_id,
            "report_title": file.filename,
            "report_content": result_content,
            "date_created": datetime.now().isoformat()
        }

        return response_data

    except Exception as e:
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)
        raise HTTPException(status_code=500, detail=f"Error analyzing report: {str(e)}")
    finally:
        # Ensure temporary file is cleaned up
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)
            
# Update the get reports endpoint as well
@router.get("/{user_id}")
async def get_reports(user_id: str):
    if not is_valid_object_id(user_id):
        raise HTTPException(status_code=400, detail="Invalid user_id format")
    
    try:
        reports = await db["reports"].find(
            {"user_id": str(user_id)}
        ).sort("date_created", -1).to_list(length=100)
        
        # Format the response
        formatted_reports = []
        for report in reports:
            formatted_report = {
                "_id": str(report["_id"]),
                "user_id": report["user_id"],
                "report_title": report["report_title"],
                "report_content": report["report_content"],
                "date_created": report["date_created"].isoformat() if isinstance(report["date_created"], (datetime, date)) else report["date_created"]
            }
            formatted_reports.append(formatted_report)
        
        return formatted_reports
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching reports: {str(e)}")
 
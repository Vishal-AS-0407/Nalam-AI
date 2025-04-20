import wave
import pyaudio
import requests
import time
import os
import streamlit as st
import asyncio
import gtts
from playsound import playsound
from googletrans import Translator
from crewai import Agent, Task, Crew, Process
from crewai import LLM

# Set page configuration
st.set_page_config(page_title="Medical Voice Assistant", page_icon="🩺", layout="wide")

# Async function to translate text to different languages
async def translate_to_language(text, lang_code):
    try:
        translator = Translator()
        translation = await translator.translate(text, dest=lang_code)
        return translation.text
    except Exception as e:
        st.error(f"Translation error: {e}")
        return text

# Function to record audio
def record_audio(filename, duration=5, rate=44100, chunk=1024):
    try:
        audio = pyaudio.PyAudio()
        stream = audio.open(format=pyaudio.paInt16, channels=1, rate=rate, input=True, frames_per_buffer=chunk)

        st.write(f"Recording for {duration} seconds...")
        progress_bar = st.progress(0)
        frames = []
        
        for i in range(int(rate / chunk * duration)):
            data = stream.read(chunk)
            frames.append(data)
            progress_bar.progress((i + 1) / int(rate / chunk * duration))
            
        stream.stop_stream()
        stream.close()
        audio.terminate()

        with wave.open(filename, 'wb') as wf:
            wf.setnchannels(1)
            wf.setsampwidth(audio.get_sample_size(pyaudio.paInt16))
            wf.setframerate(rate)
            wf.writeframes(b''.join(frames))

        return True
    except Exception as e:
        st.error(f"Recording error: {e}")
        return False

# Function to send audio to Sarvam API
def send_to_sarvam_api(filepath):
    url = "https://api.sarvam.ai/speech-to-text-translate"
    headers = {'api-subscription-key': '44de06bc-2820-4709-9f01-b60acff28d0f'}
    payload = {'model': 'saaras:v1', 'prompt': ''}

    try:
        with open(filepath, 'rb') as audio_file:
            files = [('file', (filepath, audio_file, 'audio/wav'))]
            with st.spinner("Processing audio..."):
                response = requests.post(url, headers=headers, data=payload, files=files)
        
        if response.status_code == 200:
            return response.json().get("transcript", "Transcript not found.")
        else:
            return f"Error: {response.status_code}"
    except Exception as e:
        return f"API Error: {e}"

# Setup for CrewAI
@st.cache_resource
def load_llm():
    return LLM(
        model="gemini/gemini-1.5-flash",
        temperature=0.5,
        api_key="AIzaSyBNOQJ3D5xVYeKt7xokZlQ-zXZrKwGgspE"
    )

def create_agents_and_crew(llm):
    context_interpreter = Agent(
        role="Medical Context Analyzer",
        goal="Analyze patient's medical history, reports, and past interactions to provide comprehensive context for current query",
        verbose=True,
        memory=True,
        backstory="Expert at interpreting medical records and patient history to ensure personalized and relevant medical assistance",
        llm=llm
    )

    medical_assistant = Agent(
        role="Medical Voice Assistant",
        goal="Provide personalized medical responses based on patient's history and current query",
        verbose=True,
        memory=True,
        backstory="Experienced healthcare assistant that combines medical knowledge with patient's specific medical context to provide accurate and relevant answers",
        llm=llm
    )

    context_task = Task(
        description="Analyze patient's medical records, test reports, and past interactions to establish relevant context for the current query.{user_data}",
        expected_output="A comprehensive analysis of patient's medical context relevant to their current query.",
        agent=context_interpreter
    )

    response_task = Task(
        description="Generate a personalized medical response considering patient's history, current query, and medical context{current_input}",
        expected_output="The output should be simple and crisp, that answers the user query. You should not use phrases like 'likely' and 'consult' and 'further information is needed'. For example, if the past user data contains that they ate cholesterol-rich food yesterday and today they have chest pain, you need to tell them that it is caused due to that and provide simple actionable insights like drink rasam or go for jogging etc. Keep it crisp.",
        agent=medical_assistant
    )

    crew = Crew(
        agents=[context_interpreter, medical_assistant],
        tasks=[context_task, response_task],
        process=Process.sequential
    )
    
    return crew

# Async function to process the response and translate if needed
async def process_and_translate(result, lang_code):
    if lang_code != "en":
        return await translate_to_language(result, lang_code)
    return result

# Main Streamlit app
def main():
    st.title("🩺 Medical Voice Assistant")
    st.write("This app allows you to record your medical queries and get personalized responses based on your medical history.")
    
    # Initialize session state variables if they don't exist
    if 'user_data' not in st.session_state:
        st.session_state.user_data = {
            "medical_history": "he is a healthy man",
            "test_reports": "little bit over cholesterol",
            "medications": "taking doldo 650",
            "allergies": "none",
            "past_interactions": "ate porotta yesterday night, heavy dinner with cholesterol-rich mutton gravy"
        }
    
    if 'conversation_history' not in st.session_state:
        st.session_state.conversation_history = []
    
    # Sidebar for user profile and settings
    with st.sidebar:
        st.header("User Profile")
        st.subheader("Medical History")
        
        # Make user data editable
        st.session_state.user_data["medical_history"] = st.text_area("Medical History", st.session_state.user_data["medical_history"])
        st.session_state.user_data["test_reports"] = st.text_area("Test Reports", st.session_state.user_data["test_reports"])
        st.session_state.user_data["medications"] = st.text_area("Current Medications", st.session_state.user_data["medications"])
        st.session_state.user_data["allergies"] = st.text_area("Allergies", st.session_state.user_data["allergies"])
        st.session_state.user_data["past_interactions"] = st.text_area("Recent Activities/Symptoms", st.session_state.user_data["past_interactions"])
        
        st.subheader("Language Settings")
        languages = {
            "Hindi": "hi",
            "Tamil": "ta", 
            "Telugu": "te",
            "Kannada": "kn",
            "Malayalam": "ml",
            "Gujarati": "gu",
            "Marathi": "mr",
            "Bengali": "bn",
            "Punjabi": "pa",
            "English": "en"
        }
        
        selected_language = st.selectbox(
            "Select output language",
            options=list(languages.keys()),
            index=9  # Default to English
        )
        lang_code = languages[selected_language]

    # Display conversation history
    st.subheader("Conversation History")
    for entry in st.session_state.conversation_history:
        if entry["role"] == "user":
            st.write(f"🗣️ **You:** {entry['content']}")
        else:
            st.write(f"🩺 **Assistant:** {entry['content']}")
    
    # Voice recording section
    st.subheader("Record Your Query")
    col1, col2 = st.columns(2)
    
    with col1:
        duration = st.slider("Recording duration (seconds)", 3, 15, 5)
    
    with col2:
        if st.button("🎤 Start Recording"):
            filename = f"recording_{int(time.time())}.wav"
            
            if record_audio(filename, duration):
                st.success("Recording completed!")
                
                # Process the audio file
                transcript = send_to_sarvam_api(filename)
                if transcript and not transcript.startswith("Error"):
                    st.write(f"**Your query:** {transcript}")
                    
                    # Add to conversation history
                    st.session_state.conversation_history.append({
                        "role": "user",
                        "content": transcript
                    })
                    
                    # Process with CrewAI
                    with st.spinner("Processing your query..."):
                        llm = load_llm()
                        crew = create_agents_and_crew(llm)
                        result = crew.kickoff(inputs={
                            "user_data": st.session_state.user_data,
                            "current_input": transcript
                        })
                    
                    # Translate the response if not English
                    if lang_code != "en":
                        with st.spinner("Translating response..."):
                            result = asyncio.run(translate_to_language(result, lang_code))
                    
                    # Display and add to conversation history
                    st.info(f"**Response:** {result}")
                    st.session_state.conversation_history.append({
                        "role": "assistant",
                        "content": result
                    })
                    
                    # Clean up the audio file
                    if os.path.exists(filename):
                        os.remove(filename)
                else:
                    st.error(f"Failed to process audio: {transcript}")
    
    # Alternative text input
    st.subheader("Or Type Your Query")
    text_query = st.text_input("Enter your medical question:")
    if st.button("Submit"):
        if text_query:
            # Add to conversation history
            st.session_state.conversation_history.append({
                "role": "user",
                "content": text_query
            })
            
            # Process with CrewAI
            with st.spinner("Processing your query..."):
                llm = load_llm()
                crew = create_agents_and_crew(llm)
                result = crew.kickoff(inputs={
                    "user_data": st.session_state.user_data,
                    "current_input": text_query
                })
            
            # Translate the response if not English
            if lang_code != "en":
                with st.spinner("Translating response..."):
                    result = asyncio.run(translate_to_language(result, lang_code))
            
            # Display and add to conversation history
            st.info(f"**Response:** {result}")
            st.session_state.conversation_history.append({
                "role": "assistant",
                "content": result
            })

if __name__ == "__main__":
    main()